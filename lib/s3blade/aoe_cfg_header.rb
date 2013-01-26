require 'bit-struct'

class S3Blade
	# AoE "Query Config Information" data structure.
	#
	# Ref: http://support.coraid.com/documents/AoEr11.txt, s3.2
	class AoeCfgHeader < BitStruct
		# AoE config string query/set subcommand constants
		CCMD_READ        = 0
		CCMD_TEST        = 1
		CCMD_TEST_PREFIX = 2
		CCMD_SET         = 3
		CCMD_FORCE       = 4

		# The struct	
		unsigned :buffer_count,     16
		unsigned :firmware_version, 16
		unsigned :sector_count,      8
		unsigned :version,           4
		unsigned :ccmd,              4
		unsigned :len,              16
		rest     :body
	end
end
