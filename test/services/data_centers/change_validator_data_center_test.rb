# frozen_string_literal: true

require "test_helper"
module DataCenters
  class ChangeValidatorDataCenterTest < ActiveSupport::TestCase
    include VcrHelper

    # Validators from staging, data_center_key 206264-SC-Indian/Mahe
    SPECTRUM_STAKING = {
        id: 6563, 
        name: "Spectrum Staking", 
        network: "mainnet", 
        www_url: "https://spectrumstaking.net", 
        ip_address: "185.191.127.144"
    }.freeze

    setup do
      @spectrum_staking_ip_address = SPECTRUM_STAKING[:ip_address]

      # This is the first data center before update.
      @data_center_seychelles = create(
        :data_center,
        :seychelles
      )

      # This is the correct one, updated on maxmind.
      @data_center_netherlands = build(
        :data_center,
        :netherlands
      )
      @data_center_host = create(:data_center_host, data_center: @data_center_seychelles)
      @validator = create(:validator)
      @validator_score_v1 = create(
        :validator_score_v1, 
        validator: @validator, 
        data_center_key: @data_center_seychelles.data_center_key 
      )
      @validator_ip = create(
        :validator_ip,
        :active,
        address: @spectrum_staking_ip_address, 
        data_center_host: @data_center_host,
        validator: @validator,
      )

      @vcr_namespace ||= File.join("services", "data_centers", "change_validators_data_center_test")
    end

    test "when MaxMind returns different geo data for ip (Spectrum Staking) and existing data_center_host has exactly one validator assigned "\
         "creates new data_center, assigns existing data_center_host to it "\
         "and update validator_score_v1 data_center_key" do
      vcr_cassette(@vcr_namespace, "spectrum_staking") do
        assert_equal @spectrum_staking_ip_address, @validator_ip.address
        assert_equal @validator.data_center, @data_center_seychelles
        assert_equal @validator.data_center_host, @data_center_host
        assert_equal "Seychelles", @validator.data_center.country_name
        assert_equal 206264, @validator.data_center.traits_autonomous_system_number

        assert_equal "206264-SC-Indian/Mahe", @validator_score_v1.data_center_key

        service = ChangeValidatorDataCenter.new(@validator.id)
        service.call

        @validator.reload
        @validator_score_v1.reload

        # new data center
        refute_equal @validator.data_center, @data_center_seychelles
        # old data center host
        assert_equal @validator.data_center_host, @data_center_host
        assert_equal "Netherlands", @validator.data_center.country_name
        assert_equal 206264, @validator.data_center.traits_autonomous_system_number

        assert_equal "206264-NL-Amsterdam", @validator_score_v1.data_center_key
      end
    end

    test "when MaxMind returns different geo data for ip (Spectrum Staking) and existing data_center_host has more than one validator_ip assigned "\
         "creates new data_center, new data_center_host assigned to it "\
         "assigns validator_ip to the new data_center_host and update validator_score_v1 data_center_key"  do
      vcr_cassette(@vcr_namespace, "spectrum_staking") do
        # Second validator assigned to data_center_host
        validator2 = create(:validator)
        validator_ip2 = create(
          :validator_ip, 
          :active, 
          validator: validator2,
          data_center_host: @data_center_host
        )

        assert_equal @spectrum_staking_ip_address, @validator_ip.address
        assert_equal @validator.data_center, @data_center_seychelles
        assert_equal @validator.data_center_host, @data_center_host
        assert_equal "Seychelles", @validator.data_center.country_name
        assert_equal 206264, @validator.data_center.traits_autonomous_system_number

        assert_equal "206264-SC-Indian/Mahe", @validator_score_v1.data_center_key

        service = ChangeValidatorDataCenter.new(@validator.id)
        service.call

        @validator.reload
        @validator_score_v1.reload

        # new data_center
        refute_equal @validator.data_center, @data_center_seychelles
        # new host
        refute_equal @validator.data_center_host, @data_center_host
        assert_equal "Netherlands", @validator.data_center.country_name
        assert_equal 206264, @validator.data_center.traits_autonomous_system_number

        assert_equal "206264-NL-Amsterdam", @validator_score_v1.data_center_key
      end
    end

    test "when maxmind returns the same data as present in existing data_center "\
         "and it's the same data center that is already assigned to validator "\
         "data_center, data_center_host and validator_score_v1 data_center_key should not be changed" do
      vcr_cassette(@vcr_namespace, "spectrum_staking") do
        @data_center_netherlands.save
        @data_center_host.update(data_center: @data_center_netherlands)
        @validator_score_v1.update(data_center_key: "206264-NL-Amsterdam")

        assert_equal @spectrum_staking_ip_address, @validator_ip.address
        assert_equal @validator.data_center_host, @data_center_host
        assert_equal "Netherlands", @validator.data_center.country_name
        assert_equal 206264, @validator.data_center.traits_autonomous_system_number

        assert_equal "206264-NL-Amsterdam", @validator_score_v1.data_center_key

        service = ChangeValidatorDataCenter.new(@validator.id)
        service.call

        @validator.reload
        @validator_score_v1.reload

        # the same data center
        assert_equal @validator.data_center, @data_center_netherlands
        # the same data center host
        assert_equal @validator.data_center_host, @data_center_host
        assert_equal "Netherlands", @validator.data_center.country_name
        assert_equal 206264, @validator.data_center.traits_autonomous_system_number

        assert_equal "206264-NL-Amsterdam", @validator_score_v1.data_center_key
      end
    end

    test "when maxmind returns the same data as present in existing data_center "\
         "and other data center that is already assigned to validator "\
         "assigns validator to data center from maxmind and updates data_center_key in validator_score_v1" do
      vcr_cassette(@vcr_namespace, "spectrum_staking") do

        @data_center_netherlands.save

        assert_equal @spectrum_staking_ip_address, @validator_ip.address
        assert_equal @validator.data_center, @data_center_seychelles
        assert_equal @validator.data_center_host, @data_center_host
        assert_equal "Seychelles", @validator.data_center.country_name
        assert_equal 206264, @validator.data_center.traits_autonomous_system_number

        assert_equal "206264-SC-Indian/Mahe", @validator.validator_score_v1.data_center_key

        service = ChangeValidatorDataCenter.new(@validator.id)
        service.call

        @validator.reload
        @validator_score_v1.reload

        # new data_center
        refute_equal @validator.data_center, @data_center_seychelles
        # the same data center host with new data_center 
        assert_equal @validator.data_center_host, @data_center_host
        assert_equal "Netherlands", @validator.data_center.country_name
        assert_equal "206264-NL-Amsterdam", @validator.validator_score_v1.data_center_key
        assert_equal 206264, @validator.data_center.traits_autonomous_system_number

        assert_equal "206264-NL-Amsterdam", @validator_score_v1.data_center_key
      end
    end
  end
end

