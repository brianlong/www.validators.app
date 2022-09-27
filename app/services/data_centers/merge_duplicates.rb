module DataCenters
  # WARNING: Run service with "run_update: true" argument and you'll update, 
  # without you'll get only logs and see what will be updated.
  class MergeDuplicates
    LOG_PATH = Rails.root.join("log", "#{self.name.demodulize.underscore}.log")

    def initialize(run_update: false)
      @logger ||= Logger.new(LOG_PATH)
      @run_update = run_update
    end

    def call
      log_message("Run update: #{@run_update}")

      duplicated_data_center_keys = select_duplicated_keys

      duplicated_data_center_keys.each do |dc|
        data_centers_with_validators_number = count_validators_and_gossip_nodes_in_data_center(dc)
        sorted_data_centers = sort_data_centers_by_validators_number(data_centers_with_validators_number)

        # Data center with most validators number
        main_dc = set_main_data_center(sorted_data_centers)

        sorted_data_centers.each do |entry|
          log_processed_data_center(entry)

          entry.data_center.data_center_hosts.each do |dch|
            log_processed_data_center_host(dch)

            main_dc_host = find_or_create_host(main_dc, dch)

            dch.validator_ips.each do |vip|
              update_validator_ip(vip, main_dc_host)
            end
          end
        end

        log_message("---------------", type: :info)
      end
      log_message("---------------SCRIPT HAS FINISHED----------------", type: :info)
    end


    private

    def select_duplicated_keys
      all_data_centers = DataCenter.all.group(:data_center_key).count
      all_data_centers.select { |k,v| k if v > 1 }.keys
    end

    def count_validators_and_gossip_nodes_in_data_center(dc)
      data_centers = DataCenter.where(data_center_key: dc)
      data_centers_with_validators_number = []
      
      data_centers.each do |dc|
        validator_ips_number = 0

        validator_ids = dc.data_center_hosts.map do |dch|
          validator_ips_number = dch.validator_ips.size

          dch.validator_ips.map do |vip|
            vip.validator&.id
          end
        end

        os = OpenStruct.new(
          data_center: dc,
          validators_number: validator_ids.flatten.compact.uniq.size,
          gossip_nodes_number: dc.gossip_nodes.size,
          validator_ips_number: validator_ips_number
        )

        data_centers_with_validators_number << os
      end

      data_centers_with_validators_number
    end

    def sort_data_centers_by_validators_number(data_centers)
      data_centers.sort_by! { |os| -os.validators_number }
    end

    def set_main_data_center(sorted_data_centers)
      main_dc = sorted_data_centers.shift
      message = <<-EOS
        Main dc is: #{main_dc.data_center.data_center_key}, (##{main_dc.data_center.id}) 
        with #{main_dc.validator_ips_number} validator ips 
        (#{main_dc.validators_number} validators, #{main_dc.gossip_nodes_number} gossip nodes).
      EOS

      log_message(message)
      
      main_dc.data_center
    end

    def log_processed_data_center(entry)
      dc = entry.data_center
      data_center_hosts = dc.data_center_hosts

      message = <<-EOS
        Processing data_center: #{dc.data_center_key}, (##{dc.id}) 
        with #{data_center_hosts.size} data center hosts 
        and #{entry.validator_ips_number} validator ips 
        (#{entry.validators_number} validators, #{entry.gossip_nodes_number} gossip nodes)."
      EOS

      log_message(message)
    end

    def log_processed_data_center_host(dch)
      validators_number = dch.validator_ips.map { |vip| vip.validator&.id }.compact.size
      gossip_nodes_number = dch.gossip_nodes.size 
      
      message = <<-EOS
        Processing data_center_host: #{dch.host}, (##{dch.id}) 
        with #{validators_number} validators 
        and #{gossip_nodes_number} gossip nodes.
      EOS

      log_message(message)
    end

    def find_or_create_host(data_center, data_center_host)
      if @run_update
        data_center.data_center_hosts.find_or_create_by(host: data_center_host.host)
      else
        data_center.data_center_hosts.find_or_initialize_by(host: data_center_host.host)
      end
    end

    def update_validator_ip(validator_ip, main_dc_dch)
      val = validator_ip.validator
      gossip_node = validator_ip.gossip_node

      return unless (val.present? || gossip_node.present?)

      if val.present?
        return unless vip_assigned_to_same_dc_as_validator?(val, validator_ip)
      end

      log_updated_validator_or_gossip_node_info(
        val,
        gossip_node,
        validator_ip,
        main_dc_dch
      )

      validator_ip.update(data_center_host_id: main_dc_dch.id) if @run_update == true
    end

    def vip_assigned_to_same_dc_as_validator?(val, validator_ip)
      # This checks if validator is currently assigned to data center 
      # pointed by validator_ip_active of validator.
      # 
      # Gossip node can have only one ip so it's not checked.
      return false unless val&.data_center.present? && validator_ip&.data_center.present?

      unless val.data_center.id == validator_ip.data_center.id        
        message = <<-EOS
          Validator #{val.name} (##{val.id}) current data center 
          is different than assigned to validator ip #{validator_ip.address} (##{validator_ip.id})
          validator IP will be destroyed.
        EOS

        log_message(message)

        if validator_ip.gossip_node.nil? && validator_ip.is_active == false && @run_update
          address = validator_ip.address
          id = validator_ip.id

          validator_ip.destroy 

          message = <<-EOS
            Validator IP #{address} (##{id}) destroyed.
          EOS
        end

        return false
      end

      true
    end

    def log_updated_validator_or_gossip_node_info(val, gossip_node, validator_ip, main_dc_dch)
      first_line = if val
                     "Assign validator #{val.name} (##{val.id})"
                   else
                     "Assign gossip_node #{gossip_node.account} (##{gossip_node.id})"
                   end
      message = <<-EOS
        #{first_line}
        with ip #{validator_ip.address} (##{validator_ip.id}) 
        to data center host #{main_dc_dch.host} (##{main_dc_dch.id}).
      EOS

      log_message(message)
    end

    def log_message(message, type: :info)
      # Remove unless clause to see log file from tests.
      @logger.send(type, message.squish) unless Rails.env.test?
    end
  end
end
