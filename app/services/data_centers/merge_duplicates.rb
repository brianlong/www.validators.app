module DataCenters
  class MergeDuplicates
    LOG_PATH = Rails.root.join("log", "#{self.name.demodulize.underscore}.log")

    def initialize
      @logger ||= Logger.new(LOG_PATH)
    end


    def call
      duplicated_data_center_keys = select_duplicated_keys

      duplicated_data_center_keys.each do |dc|
        data_centers_with_validators_number = count_validators_in_data_center(dc)
        
        sorted_data_centers = sort_data_centers_by_validators_number(data_centers_with_validators_number)

        main_dc = sorted_data_centers.shift
        log_message("Main dc is: #{main_dc.data_center.data_center_key}, (##{main_dc.data_center.id}) with #{main_dc.validators_number} validator ips (validators as well).")
        main_dc = main_dc.data_center

        sorted_data_centers.each do |entry|
          dc = entry.data_center
          data_center_hosts = dc.data_center_hosts

          log_message("Processing data_center: #{dc.data_center_key}, (##{dc.id}) with #{data_center_hosts.size} data center hosts and #{data_center_hosts.map { |dch| dch.validator_ips.size }.sum } validator ips (validators as well).")

          data_center_hosts.each do |dch|
            log_message("Processing data_center_host: #{dch.host}, (##{dch.id}) with #{dch.validator_ips.size} validators.")
            main_dc_host = main_dc.data_center_hosts.find_or_initialize_by(host: dch.host)

            dch.validator_ips.each do |vip|
              update_validator_ip(vip, main_dc_host)
            end
          end
        end

        log_message("---------------", type: :info)
      end
    end

    private

    def select_duplicated_keys
      all_data_centers = DataCenter.all.group(:data_center_key).count
      all_data_centers.select { |k,v| k if v > 1 }.keys
    end

    def count_validators_in_data_center(dc)
      data_centers = DataCenter.where(data_center_key: dc)
      data_centers_with_validators_number = []

      data_centers.each do |dc| 
        os = OpenStruct.new(
          data_center: dc,
          validators_number: dc.data_center_hosts.map { |dch| dch.validator_ips.size }.sum
        )
        data_centers_with_validators_number << os
      end

      data_centers_with_validators_number
    end

    def sort_data_centers_by_validators_number(data_centers)
      data_centers.sort! { |os| -os.validators_number }
    end

    def update_validator_ip(validator_ip, main_dc_dch)
      val = validator_ip.validator
              
      return unless val

      log_message("Assign validator #{val.name} (##{val.id}) with ip #{validator_ip.address} (##{validator_ip.id}) to data center host #{main_dc_dch.host} (##{main_dc_dch.id}).")
      # vip.update(data_center_host_id: existing_main_dc_dch.id)
    end

    def log_message(message, type: :info)
      # Remove unless clause to see log file from tests.
      @logger.send(type, message.squish) unless Rails.env.test?
    end
  end
end