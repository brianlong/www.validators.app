module DataCenters
  # WARNING: Run service with "run_destroy: true" argument and you'll destroy data centers, 
  # without you'll get only logs and see what will be updated.
  class RemoveWithoutValidatorsAndGossipNodes
    LOG_PATH = Rails.root.join("log", "#{self.name.demodulize.underscore}.log")

    def initialize(run_destroy: false)
      @logger ||= Logger.new(LOG_PATH)
      @run_destroy = run_destroy
      @total_removed_data_centers = 0
    end

    def call
      log_message("Run destroy: #{@run_destroy}")

      DataCenter.where(data_center_key: select_duplicated_keys).includes(:validators, :data_center_hosts).each do |dc|
        validators_number, gossip_nodes_number = count_validators_and_gossip_nodes(dc)

        next if validators_number > 0 || gossip_nodes_number > 0

        dc.destroy if @run_destroy
        @total_removed_data_centers += 1
        message = <<-EOS
          Data center #{dc.data_center_key} (##{dc.id}) has been removed with its 
          data_center_hosts (#{dc.data_center_hosts.size}). 
          Validators number: #{validators_number}, gossip nodes number #{gossip_nodes_number}.
        EOS

        log_message(message)
      end

      log_message("---------------", type: :info)
      log_message("Total removed data centers: #{@total_removed_data_centers}", type: :info)
    end

    def log_message(message, type: :info)
      # Remove unless clause to see log file from tests.
      @logger.send(type, message.squish) unless Rails.env.test?
    end

    private

    def select_duplicated_keys
      all_data_centers = DataCenter.all.group(:data_center_key).count
      all_data_centers.select { |k,v| k if v > 1 }.keys
    end

    def count_validators_and_gossip_nodes(data_center)
      validators_number = data_center.data_center_hosts.map do |dch| 
        dch.validator_ips.map do |vip|
          vip.validator&.id
        end
      end.flatten.compact.uniq.size

      gossip_nodes_number = data_center.gossip_nodes.size

      [validators_number, gossip_nodes_number]
    end
  end
end
