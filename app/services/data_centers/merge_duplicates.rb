module DataCenters
  # WARNING: Run service with "perform_update: true" argument and you'll update, 
  # without you'll get only logs and see what will be updated.
  class MergeDuplicates
    LOG_PATH = Rails.root.join("log", "#{self.name.demodulize.underscore}.log")

    def initialize(perform_update: false)
      @perform_update = perform_update
      @logger ||= Logger.new(LOG_PATH)
    end

    def call
      duplicated_data_center_keys = select_duplicated_keys

      duplicated_data_center_keys.each do |dc_key|
        sorted_data_centers = sort_data_centers_by_created_at(dc_key)
        main_dc = sorted_data_centers.last
        log_chosen_data_center(main_dc, sorted_data_centers)

        sorted_data_centers.each do |dc|
          next if dc == main_dc

          dc.data_center_hosts.each do |dch|
            # copy data_center_hosts from duplicate to main data_center
            main_dc_host = find_or_create_host(main_dc, dch)

            dch.validator_ips.each do |ip|
              update_validator_ip(ip, main_dc_host)
            end
          end
        end
      end
    end

    private

    def select_duplicated_keys
      all_data_centers = DataCenter.all.group(:data_center_key).count
      all_data_centers.select { |k,v| k if v > 1 }.keys
    end

    def sort_data_centers_by_created_at(dc_key)
      DataCenter.where(data_center_key: dc_key).order(created_at: :asc)
    end

    def find_or_create_host(data_center, data_center_host)
      if @perform_update
        data_center.data_center_hosts.find_or_create_by(host: data_center_host.host)
      else
        data_center.data_center_hosts.find_or_initialize_by(host: data_center_host.host)
      end
    end

    def update_validator_ip(validator_ip, main_dc_dch)
      val = validator_ip.validator
      gossip_node = validator_ip.gossip_node

      log_updated_validator_or_gossip_node_info(
        val,
        gossip_node,
        validator_ip,
        main_dc_dch
      )

      validator_ip.update(data_center_host_id: main_dc_dch.id) if @perform_update == true
    end

    # logging

    def log_message(message, type: :info)
      # Remove unless clause to see log file from tests.
      @logger.send(type, message.squish) unless Rails.env.test?
    end

    def log_updated_validator_or_gossip_node_info(val, gossip_node, validator_ip, main_dc_dch)
      first_line = if val
                     "Assign validator #{val.name} (##{val.id})"
                   elsif gossip_node
                     "Assign gossip_node #{gossip_node.account} (##{gossip_node.id})"
                   else
                     "Assign validator_ip without node nor validator (##{validator_ip.id})"
                   end
      message = <<-EOS
        #{first_line}
        with ip #{validator_ip.address} (##{validator_ip.id}) 
        to data center host #{main_dc_dch.host} (##{main_dc_dch.id}).
      EOS

      log_message(message)
    end

    def log_chosen_data_center(data_center, sorted_data_centers)
      message = <<-EOS
        Chosen data center #{data_center.data_center_key} (##{data_center.id})
        created at #{data_center.created_at}.
        available options: #{sorted_data_centers.map { |dc| "##{dc.id} (#{dc.created_at})" }.join(", ")}
      EOS

      log_message(message)
    end

  end
end
