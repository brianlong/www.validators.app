module DataCenters
  # WARNING: Run service with "run_destroy: true" argument and you'll destroy data centers, 
  # without you'll get only logs and see what will be updated.
  class RemoveWithoutValidators
    LOG_PATH = Rails.root.join("log", "#{self.name.demodulize.underscore}.log")

    def initialize(run_destroy: false)
      @logger ||= Logger.new(LOG_PATH)
      @run_destroy = run_destroy
    end

    def call
      DataCenter.all.includes(:validators, :data_center_hosts).each do |dc|
        validators_number = dc.data_center_hosts.map { |dch| dch.validator_ips.size }.sum
        gossip_nodes_number = dc.gossip_nodes.size

        next if validators_number > 0 || gossip_nodes_number > 0

        dc.destroy if @run_destroy

        log_message("Data center #{dc.data_center_key} (##{dc.id}) has been removed with its data_data_center_hosts (#{dc.data_center_hosts.size}), validators number: #{validators_number}, gossip nodes number #{gossip_nodes_number}.")
      end

      log_message("---------------", type: :info)
    end

    def log_message(message, type: :info)
      # Remove unless clause to see log file from tests.
      @logger.send(type, message.squish) unless Rails.env.test?
    end
  end
end