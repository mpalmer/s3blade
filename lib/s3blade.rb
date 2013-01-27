require 'socket'
require 'ethernet'
require 'aws-sdk'
require 's3blade/aoe_header'
require 's3blade/aoe_cfg_header'
require 's3blade/ata_command'
require 's3blade/ata_identify_device'

class S3Blade
	# Create us an s3blade.  Options are:
	#
	#   :shelf (required) -- The numeric ID of the shelf number of this AoE
	#      volume.  Must be an integer between 0 and 65534.
	#
	#   :blade (required) -- The numeric ID of the blade number of this AoE
	#      volume.  Despite the standard saying this can be between 0 and
	#      254, the standard Linux AoE client implementation only supports
	#      blade IDs between 0 and 15, so that's all we'll accept, for
	#      safety's sake.
	#
	#   :s3_endpoint (optional; default 's3.amazonaws.com') -- The FQDN of
	#      the S3-like service we're storing blocks in.  This endpoint must
	#      support HTTPS.
	#
	#   :s3_access_key (required) -- The access key for your S3-like service.
	#
	#   :s3_secret_key (required) -- The secret key for your S3-like service.
	#
	#   :s3_bucket (required) -- The bucket you wish to store your blocks in.
	#      The bucket must already exist and be available to your account.
	#
	#   :object_name_pattern (optional; default 's3blade/e%s.%b_%i') -- Define
	#      the names of the objects that store your blocks.  %s will be
	#      replaced with the shelf ID, %b with the blade ID, and %i with the
	#      block number.
	#
	#   :network_device (required) -- The name of the network device you wish
	#      s3blade to listen on.
	#
	#   :device_size (required) -- The size of the device you wish to create,
	#      IN BYTES.  We don't go for any of that fancy SI suffix business
	#      here, do that in your command line wrapper or something.
	#
	#   :serial (optional; default (<shelf>.<blade>:<hostname>") -- Set the
	#      "serial number" of the AoE device, as reported by the ATA
	#      "identify device" command to something other than the default.
	#
	#   :debug (optional; default false) -- Whether the object will dump a
	#      whole pile of debugging output to stderr.
	#      
	def initialize(opts)
		@shelf               = opts[:shelf] or
		                       raise ArgumentError.new(":shelf is a required option to S3Blade#initialize")
		if !@shelf.is_a? Fixnum or @shelf < 0 or @shelf > 65534
			raise ArgumentError.new(":shelf must be an integer between 0 and 65534")
		end
		@blade               = opts[:blade] or
		                       raise ArgumentError.new(":blade is a required option to S3Blade#initialize")
		if !@blade.is_a? Fixnum or @blade < 0 or @blade > 15
			raise ArgumentError.new(":blade must be an integer between 0 and 15")
		end
		@s3_endpoint         = opts[:s3_endpoint] ||
		                       's3.amazonaws.com'
		@s3_access_key       = opts[:s3_access_key] or
		                       raise ArgumentError.new(":s3_access_key is a required option to S3Blade#initialize")
		@s3_secret_key       = opts[:s3_secret_key] or
		                       raise ArgumentError.new(":s3_secret_key is a required option to S3Blade#initialize")
		@s3_bucket           = opts[:s3_bucket] or
		                       raise ArgumentError.new(":s3_bucket is a required option to S3Blade#initialize")
		@object_name_pattern = opts[:object_name_pattern] ||
		                       "s3blade/e%s.%b_%i"
		@network_device      = opts[:network_device] or
		                       raise ArgumentError.new(":network_device is a required option to S3Blade#initialize")
		@device_size         = opts[:device_size] or
		                       raise ArgumentError.new(":device_size is a required option to S3Blade#initialize")
		@serial              = opts[:serial] or
		                       "#{@shelf}.#{@blade}:#{@hostname}"
		@debug               = opts[:debug].nil? ? false : opts[:debug]

		@sector_count        = (@device_size / 512.0).ceil
		@object_name_pattern = @object_name_pattern.sub('%s', @shelf.to_s).sub('%b', @blade.to_s)
	end

	# Fire up the s3blade listener and respond to requests.  Will keep going
	# and going and going until told to stop by calling the 'stop' method.
	def run
		@stop = false
		
		s3 = AWS::S3.new(:access_key_id     => @s3_access_key,
		                 :secret_access_key => @s3_secret_key,
		                 :s3_endpoint       => @s3_endpoint)

		@bucket = s3.buckets[@s3_bucket]

		sock = Ethernet::FrameSocket.new(@network_device, 0x88A2)
		
		broadcast_presence(sock)

		until @stop
			# 12000 octets ought to be enough for anyone...
			pkt, src = sock.recv_from(12000)
			
			aoe_hdr = AoeHeader.new(pkt)

			next unless (aoe_hdr.shelf == @shelf and aoe_hdr.blade == @blade) or
							(aoe_hdr.shelf == 0xffff and aoe_hdr.blade == 0xff)

			resp = if aoe_hdr.command == AoeHeader::CMD_QUERY_CONFIG
				cfg_hdr = AoeCfgHeader.new(aoe_hdr.payload)
				
				if cfg_hdr.ccmd == AoeCfgHeader::CCMD_READ
					answer_config_query(src, aoe_hdr.tag, sock)
				else
					# Unsupported config command... no biscuit for you!
					err cfg_hdr.inspect_detailed
					nil
				end
			elsif aoe_hdr.command == AoeHeader::CMD_ATA_COMMAND
				ata_cmd = AtaCommand.new(aoe_hdr.payload)
				ata_resp = ata_handler(ata_cmd)
				
				unless ata_resp.nil?
					aoe_resp = AoeHeader.new
					aoe_resp.version = aoe_hdr.version
					aoe_resp.shelf = @shelf
					aoe_resp.blade = @blade
					aoe_resp.command = AoeHeader::CMD_ATA_COMMAND
					aoe_resp.tag = aoe_hdr.tag
					aoe_resp.response = 1
					aoe_resp.payload = ata_resp.to_s
					aoe_resp
				end
			else
				# Unsupported AoE command
				err aoe_hdr.inspect_detailed
				nil
			end
			
			if resp
				sock.send_to(src, resp.to_s)
			end
		end  # Aaaaand back around we go!
		
		sock.close
	end

	# Signal the event loop to stop running.
	def stop
		@stop = true
	end

	def answer_config_query(to, tag, sock)
		cfg_hdr = AoeCfgHeader.new
		cfg_hdr.buffer_count = 16
		cfg_hdr.firmware_version = 0
		cfg_hdr.sector_count = 2
		cfg_hdr.version = 1
		cfg_hdr.ccmd = AoeCfgHeader::CCMD_READ

		aoe_hdr = AoeHeader.new
		aoe_hdr.payload = cfg_hdr.to_s
		aoe_hdr.version = 1
		aoe_hdr.shelf = @shelf
		aoe_hdr.blade = @blade
		aoe_hdr.command = AoeHeader::CMD_QUERY_CONFIG
		aoe_hdr.tag = tag
		aoe_hdr.response = 1

		sock.send_to(to, aoe_hdr.to_s)
	end

	def ata_handler(ata_cmd)
		case ata_cmd.cmd_status
			when AtaCommand::IDENTIFY_DEVICE   then ata_identify_device(ata_cmd)
			when AtaCommand::READ_SECTORS_EXT  then ata_read_sectors(ata_cmd)
			when AtaCommand::WRITE_SECTORS_EXT then ata_write_sectors(ata_cmd)
		else
			err ata_cmd.inspect_detailed
			nil
		end
	end

	def ata_identify_device(cmd)
		ident = AtaIdentifyDevice.new
		ident.serial = @serial
		ident.firmware_version = "dev"
		ident.model = "S3Blade"
		ident.multiple_size = 128
		ident.sector_count = @sector_count
		ident.max_lba = @sector_count

		ident.lba48_supported = 1
		ident.lba48_enabled = 1

		resp = AtaCommand.new
		resp.cmd_status = 0x40  # It's magic!
		resp.lba = cmd.lba
		resp.data = ident.to_s

		resp
	end

	def ata_read_sectors(cmd)
		resp = AtaCommand.new
		# Not really error, just LBA48
		resp.error_flag = 1
		resp.cmd_status = 0x40  # It's magic!
		resp.lba = cmd.lba

		data = ""
		cmd.sector_count.times do |sec|
			abs_sector = cmd.first_sector+sec
			objname = sector_filename(abs_sector)
			debug "Looking for sector #{objname}"
			obj = @bucket.objects[objname]
			if obj.exists?
				debug "existing"
				sector_data = obj.read
				if sector_data.length != 512
					debug "OMFG, short read!"
				end
				sector_data += "\0" * (512 - sector_data.length)
				data << sector_data
			else
				debug "non-existing"
				data << ("\0" * 512)
			end
			
			debug "#{abs_sector}: data is now #{data.length} bytes long"
		end

		resp.data = data
		resp
	end

	def ata_write_sectors(cmd)
		resp = AtaCommand.new
		# Not really error, just LBA48
		resp.error_flag = 1
		resp.cmd_status = 0x40  #It's magic!
		resp.lba = cmd.lba
		resp.write = 1
		
		cmd.sector_count.times do |sec|
			abs_sector = cmd.first_sector + sec
			obj = @bucket.objects[sector_filename(abs_sector)]
			f = sec*512
			l = ((sec+1)*512)-1
			data = cmd.data[f..l].to_s
			if data == "\0" * 512
				debug "Deleting sector #{abs_sector} because it's NULLs ALL THE WAY DOWN"
				obj.delete
			else
				debug "Writing a #{data.length} byte #{data.class} to sector #{abs_sector}"
				obj.write(data)
			end
		end
		
		resp
	end
	
	private
	def broadcast_presence(sock)
		aoe_hdr = AoeHeader.new
		aoe_hdr.version = 0
		
		sock.send_to("\xff"*6, aoe_hdr.to_s)
	end
	
	def sector_filename(s)
		@object_name_pattern.sub('%i', s.to_s)
	end
	
	def err(*s)
		$stderr.puts(*s)
	end
	
	def debug(*s)
		$stderr.puts(*s) if @debug
	end
end
