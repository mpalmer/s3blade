require 'bit-struct'

class S3Blade
	# AoE packet header structure and constants.
	#
	# Ref: http://support.coraid.com/documents/AoEr11.txt, s2
	class AoeHeader < BitStruct
		# AoE command constants
		CMD_ATA_COMMAND  = 0
		CMD_QUERY_CONFIG = 1
		
		# The AoE packet header struct in all its glory
		unsigned :version,     4, "AoE protocol version"
		unsigned :response,    1, "Is this packet a response?"
		unsigned :error,       1, "Is this packet an error?"
		unsigned :unused,      2
		unsigned :error_code,  8, "Error code"
		unsigned :shelf,      16, "Shelf ID for the AoE device"
		unsigned :blade,       8, "Blade ID for the AoE device"
		unsigned :command,     8, "Command identifier"
		unsigned :tag,        32, "Unique command/response pair identifier"
		rest     :payload
	end
end
