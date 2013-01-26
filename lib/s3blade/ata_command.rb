require 'bit-struct'

class S3Blade
	# Struct and constants for the ATA command header.
	#
	# Ref: http://support.coraid.com/documents/AoEr11.txt, s3.1
	class AtaCommand < BitStruct
		# ATA commands that we support
		IDENTIFY_DEVICE   = 0xEC
		READ_SECTORS_EXT  = 0x24
		WRITE_SECTORS_EXT = 0x34

		# The ATA command header.
		unsigned :z0, 1
		unsigned :error_flag, 1
		unsigned :z1, 1
		unsigned :device_head, 1
		unsigned :z2, 2
		unsigned :async, 1
		unsigned :write, 1
		unsigned :err_feature, 8
		unsigned :sector_count, 8
		unsigned :cmd_status, 8
		vector	:lba, :length => 6 do
			unsigned :n, 8
		end
		unsigned :reserved, 16
		rest     :data
		
		def first_sector
			self.lba[0].n +
			256*self.lba[1].n +
			256*256*self.lba[2].n +
			256*256*256*self.lba[3].n +
			256*256*256*256*self.lba[4].n +
			256*256*256*256*256*self.lba[5].n
		end
	end
end
