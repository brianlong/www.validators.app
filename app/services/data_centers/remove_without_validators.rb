module DataCenters
  class RemoveWithoutValidators
    LOG_PATH = Rails.root.join("log", "remove_without_validators.log")

    def initialize
      @logger ||= Logger.new(LOG_PATH)
    end

    def call
      DataCenter.all.includes(:validators).each do |dc|
        validators_number = dc.validators.size
        next if validators_number > 0

        log_message("Data center #{dc.data_center_key} (##{dc.id}) will be removed, validators number: #{validators_number}.")
      end

      log_message("---------------", type: :info)
    end

    def log_message(message, type: :info)
      # Remove unless clause to see log file from tests.
      @logger.send(type, message.squish) unless Rails.env.test?
    end
  end
end