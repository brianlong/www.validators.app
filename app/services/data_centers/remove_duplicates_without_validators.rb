module DataCenters
  class RemoveDuplicatesWithoutValidators
    LOG_PATH = Rails.root.join("log", "#{self.name.demodulize.underscore}.log")

    def initialize
      @logger ||= Logger.new(LOG_PATH)
    end

    def call
      DataCenter.all.includes(:validators).each do |dc|
        validators_number = dc.validators.size
        gossip_nodes_number = dc.gossip_nodes.size
        # duplicates = DataCenter.where(data_center_key: dc.data_center_key)

        next if validators_number > 0 || gossip_nodes_number > 0 # || duplicates.size < 2

        log_message("Data center #{dc.data_center_key} (##{dc.id}) will be removed, validators number: #{validators_number}, gossip nodes number #{gossip_nodes_number}.")
      end

      log_message("---------------", type: :info)
    end

    def log_message(message, type: :info)
      # Remove unless clause to see log file from tests.
      @logger.send(type, message.squish) unless Rails.env.test?
    end
  end
end