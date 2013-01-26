require 'bit-struct'

class S3Blade
	# The ATA "identify device" response struct.  OMFG hueg.
	#
	# Ref: ATA/ATAPI-6 specification, T13/1410D, s8.15
	class AtaIdentifyDevice < BitStruct
		octets   :w0_9, 160
		string   :serial, 160, :swab => true, :space_padded => true
		octets   :w20_22, 48
		string   :firmware_version, 64, :swab => true, :space_padded => true
		string   :model, 320, :swab => true, :space_padded => true
		unsigned :multiple_size, 16
		octets   :w48, 16
		unsigned :w49b0_7, 8
		unsigned :dma_supported, 1
		unsigned :lba_supported, 1
		unsigned :iordy_disabled, 1
		unsigned :iordy_supported, 1
		unsigned :w49b12, 1
		unsigned :standby_timers_supported, 1
		unsigned :w49b14_15, 2
		unsigned :standby_timer_minimum, 1
		unsigned :w50b1_13, 13
		unsigned :set_to_one, 1
		unsigned :set_to_zero, 1
		unsigned :w51_52, 32
		unsigned :field_validity, 16
		octets   :w54_58, 80
		unsigned :multiple_sector_default, 8
		unsigned :multiple_sector_enable, 1
		unsigned :w59b9_15, 7
		unsigned :sector_count, 32, :endian => :little
		octets   :w62_74, 208
		unsigned :queue_depth, 4
		unsigned :w75b5_15, 12
		octets   :w76_79, 64
		unsigned :major_version, 16
		unsigned :minor_version, 16

		### Features Supported ###
		unsigned :release_interrupt_supported, 1
		unsigned :lookahead_supported, 1
		unsigned :write_cache_supported, 1
		unsigned :packet_commands_supported, 1
		unsigned :power_management_supported, 1
		unsigned :removable_media_supported, 1
		unsigned :security_mode_supported, 1
		unsigned :smart_supported, 1

		unsigned :w82b15, 1
		unsigned :nop_command_supported, 1
		unsigned :read_buffer_command_supported, 1
		unsigned :write_buffer_command_supported, 1
		unsigned :w82b11, 1
		unsigned :host_protected_area_supported, 1
		unsigned :device_reset_supported, 1
		unsigned :service_interrupt_supported, 1

		unsigned :see_address_offset_reserved_area_boot, 1
		unsigned :set_features_required, 1
		unsigned :power_up_in_standby_supported, 1
		unsigned :removable_media_status_supported, 1
		unsigned :advanced_power_mgmt_supported, 1
		unsigned :cfa_features_supported, 1
		unsigned :queued_dma_supported, 1
		unsigned :download_microcode_supported, 1

		unsigned :shall_be_set_to_0, 1
		unsigned :shall_be_set_to_1, 1
		unsigned :flush_cache_ext_supported, 1
		unsigned :mandatory_flush_cache_supported, 1
		unsigned :device_config_overlay_supported, 1
		unsigned :lba48_supported, 1
		unsigned :automatic_acoustic_management_supported, 1
		unsigned :set_max_security_supported, 1

		
		unsigned :w84b6_7, 2
		unsigned :general_purpose_logging_supported, 1
		unsigned :w84b4, 1
		unsigned :media_card_pass_through_supported, 1
		unsigned :media_serial_number_supported, 1
		unsigned :smart_self_test_supported, 1
		unsigned :smart_error_logging_supported, 1

		unsigned :shall_be_set_to_zero, 1
		unsigned :shall_be_set_to_one, 1
		unsigned :w84b8_13, 6

		### Features Enabled ###
		unsigned :release_interrupt_enabled, 1
		unsigned :lookahead_enabled, 1
		unsigned :write_cache_enabled, 1
		unsigned :packet_commands_enabled, 1
		unsigned :power_management_enabled, 1
		unsigned :removable_media_enabled, 1
		unsigned :security_mode_enabled, 1
		unsigned :smart_enabled, 1

		unsigned :w85b15, 1
		unsigned :nop_command_enabled, 1
		unsigned :read_buffer_command_enabled, 1
		unsigned :write_buffer_command_enabled, 1
		unsigned :w85b11, 1
		unsigned :host_protected_area_enabled, 1
		unsigned :device_reset_enabled, 1
		unsigned :service_interrupt_enabled, 1

		unsigned :see_address_offset_reserved_area_boot_2, 1
		unsigned :set_features_required_2, 1
		unsigned :power_up_in_standby_enabled, 1
		unsigned :removable_media_status_enabled, 1
		unsigned :advanced_power_mgmt_enabled, 1
		unsigned :cfa_features_enabled, 1
		unsigned :queued_dma_enabled, 1
		unsigned :download_microcode_enabled, 1

		unsigned :w86b14_15, 2
		unsigned :flush_cache_ext_enabled, 1
		unsigned :flush_cache_enabled, 1
		unsigned :device_config_overlay_enabled, 1
		unsigned :lba48_enabled, 1
		unsigned :automatic_acoustic_management_enabled, 1
		unsigned :set_max_security_enabled, 1
		
		unsigned :w87b6_7, 2
		unsigned :general_purpose_logging_enabled, 1
		unsigned :w87b4, 1
		unsigned :media_card_pass_through_enabled, 1
		unsigned :media_serial_number_valid, 1
		unsigned :smart_self_test_enabled, 1
		unsigned :smart_error_logging_enabled, 1

		unsigned :shall_be_set_to_zero_again, 1
		unsigned :shall_be_set_to_one_again, 1
		unsigned :w87b8_13, 6

		unsigned :ultra_dma, 16
		unsigned :secure_erase_time, 16
		unsigned :enhanced_erase_time, 16
		unsigned :power_mgmt_level, 16
		unsigned :password_revision, 16
		unsigned :config_test_results, 16
		unsigned :noise_level, 16
		octets   :w95_99, 80
		unsigned :max_lba, 64, :endian => :little
		octets   :w104_126, 368
		unsigned :removal_status_support, 16
		unsigned :security_status, 16
		octets   :w12, 496
		unsigned :cfa_power_mode, 16
		octets   :w13, 240
		string   :media_serial_number, 480
		octets   :w14, 784
		unsigned :checksum_enabled, 8
		unsigned :checksum, 8
	end
end
