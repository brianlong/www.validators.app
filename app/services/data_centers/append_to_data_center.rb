# frozen_string_literal: true
module DataCenters
  class AppendToDataCenter
    def initialize(data_center, data_center_host: nil)
      raise ArgumentError, "Please provide data center" unless data_center.present? && data_center.is_a?(DataCenter)

      @data_center = data_center
      @data_center_host = set_host(data_center_host)
    end

    def call(validator)
      validator_ip = set_validator_ip(validator)
      append_to_data_center(validator_ip)
    end

    private
    def set_host(data_center_host)
      if data_center_host && data_center_host.is_a?(DataCenterHost)
        data_center_host
      else
        DataCenterHost.create(host: nil, data_center: @data_center)
      end
    end

    def set_validator_ip(validator)
      if validator.validator_ip_active
        validator.validator_ip_active
      else
        validator.validator_ips.create(
          address: nil, 
          is_active: true
        )
      end
    end

    def append_to_data_center(validator_ip)
      validator_ip.update(data_center_host: @data_center_host)
    end
  end
end