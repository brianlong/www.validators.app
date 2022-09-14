module DataCenters
  class MergeDuplicates
    LOG_PATH = Rails.root.join("log", "#{self.name.demodulize.underscore}.log")

    def initialize
      @logger ||= Logger.new(LOG_PATH)
    end

    def call
      all_data_centers = DataCenter.all.group(:data_center_key).count
      duplicated_data_center_keys = all_data_centers.select { |k,v| k if v > 1 }.keys

      duplicated_data_center_keys.each do |dc|
        data_centers = DataCenter.where(data_center_key: dc)

        data_centers_with_validators_size = []
        data_centers.each do |dc| 
          os = OpenStruct.new(
            data_center: dc,
            validators_number: dc.validators.size
          )
          data_centers_with_validators_size << os
        end

        sorted_data_centers = data_centers_with_validators_size.sort { |os| os.validators_number }

        main_dc = sorted_data_centers.shift
        log_message("Main dc is: #{main_dc.data_center.data_center_key}, (##{main_dc.data_center.id}) with #{main_dc.validators_number} validators.")
        main_dc = main_dc.data_center

        sorted_data_centers.each do |entry|
          dc = entry.data_center
          log_message("Assign #{dc.validators.size} validators from #{dc.data_center_key} (##{dc.id}) to main dc (##{main_dc.id}).")

          duplicated_data_center_hosts = dc.data_center_hosts

          duplicated_data_center_hosts.each do |dch|
            existing_main_dc_dch = main_dc.data_center_hosts.find_or_initialize_by(host: dch.host)
            dch.validator_ips.each do |vip|
              val = vip.validator
              
              next unless val

              log_message("Assign validator #{val.name} (##{val.id}) with ip ##{vip.address} to data center host #{existing_main_dc_dch.host} (##{existing_main_dc_dch.id}).")
              # vip.update(data_center_host_id: existing_main_dc_dch.id)
            end
          end
        end

        log_message("---------------", type: :info)

      end

    end

    private 
    def log_message(message, type: :info)
      # Remove unless clause to see log file from tests.
      @logger.send(type, message.squish) unless Rails.env.test?
    end
  end
end