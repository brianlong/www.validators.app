module DataCenters
  # WARNING: Run service with "run_update: true" argument and you'll update, 
  # without you'll get only logs and see what will be updated.
  class MergeDuplicates
    def initialize(switch_all: true)
      @switch_all = switch_all
      @validator_ips_to_detach = []
    end

    def call
      duplicated_data_center_keys = select_duplicated_keys

      duplicated_data_center_keys.each do |dc_key|
        puts dc_key
        sorted_data_centers = sort_data_centers_by_created_at(dc_key)
        main_dc = sorted_data_centers.last
        main_dc_host = main_dc.data_center_hosts.last
        @validator_ips_to_switch = []

        sorted_data_centers.each do |dc|
          next if dc == main_dc
          dc.validators.joins(:validator_ips).each do |val|
            append_ip_to_update(val.validator_ip_active, val.is_active)
          end

          dc.gossip_nodes.joins(:validator_ip).each do |node|
            append_ip_to_update(node.validator_ip_active, node.is_active)
          end
        end
        switch_validator_ips(main_dc_host)
        puts "switched validators and nodes: #{@validator_ips_to_switch.count}"
      end
      detach_validator_ips
      puts "detached validator_ips: #{@validator_ips_to_detach.count}"
    end

    private

    def select_duplicated_keys
      all_data_centers = DataCenter.all.group(:data_center_key).count
      all_data_centers.select { |k,v| k if v > 1 }.keys
    end

    def sort_data_centers_by_created_at(dc_key)
      DataCenter.where(data_center_key: dc_key).order(created_at: :asc)
    end

    def append_ip_to_update(val_ip, detach)
      detach && !@switch_all ?  @validator_ips_to_detach.push(val_ip.id) : @validator_ips_to_switch.push(val_ip.id)
    end

    def switch_validator_ips(main_dc_host)
      ValidatorIp.where(id: @validator_ips_to_switch).update_all(data_center_host_id: main_dc_host.id)
    end

    def detach_validator_ips
      ValidatorIp.where(id: @validator_ips_to_detach).update_all(data_center_host_id: nil)
    end
  end
end
