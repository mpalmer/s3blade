require File.expand_path('../test_helper', __FILE__)
require 's3blade/aoe_header'

class AoeHeaderTest < Test::Unit::TestCase
	def test_request_construction
		h = S3Blade::AoeHeader.new
		
		h.version = 0
		h.response = 1
		h.shelf = 69
		h.blade = 8
		h.command = 1
		h.tag = 0
		
		assert_equal "\x08\x00\x00\x45\x08\x01\x00\x00\x00\x00",
		             h.to_s
	end
end
