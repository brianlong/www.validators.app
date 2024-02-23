# frozen_string_literal: true

module DataCenters
  class ChangeValidatorDataCenter
    LOG_PATH = Rails.root.join("log", "change_validator_data_center.log")
    SEPARATOR = "-" * 50

    def initialize(max_mind_client: MaxMindClient)
      # Service responsible for appending geo data
      @ip_service = DataCenters::CheckIpInfoService.new

      @update_score = false
      @max_mind_client = max_mind_client
      @logger ||= Logger.new(LOG_PATH)
    end

    def call(validator_id)
      find_validator(validator_id)
      unless @validator
        log_message(SEPARATOR)
        return false
      end

      find_validator_ip
      unless @validator_ip
        log_message(SEPARATOR)
        return false
      end

      find_data_center_host
      max_mind_results_for_ip
      data_center_from_max_mind_data
      create_or_update_data_center
      assign_validator_to_new_data_center
    end

    private

    def find_validator(validator_id)
      @validator = Validator.find_by(id: validator_id)

      if @validator
        log_message("Validator #{@validator.name} (##{@validator.id}) found.")
      else
        log_message(
          "Validator with id: #{validator_id} has not been found, script is finished.",
          type: :error
        )
      end
    end

    def find_validator_ip
      @validator_ip = @validator.validator_ip_active

      if @validator_ip
        message = <<-EOS
          Validator Ip (##{@validator_ip.id}) for validator #{@validator.name} 
          (##{@validator.id}) has been found, 
          ip address: #{@validator_ip.address}
        EOS

        log_message(message)        
      else
        message = <<-EOS
          Validator Ip (#{@validator_ip.id}) for validator #{@validator.name} 
          (##{@validator.id}) has not been found, script is finished."
        EOS

        log_message(message, type: :error)

        return false
      end
    end

    def find_data_center_host
      @data_center_host = @validator_ip.data_center_host

      if @data_center_host
        message = <<-EOS
          Data center host (##{@data_center_host.id}) has been found, 
        EOS

        log_message(message)        
      else
        message = "Data center host has not been found, will be created later."


        log_message(message, type: :error)

        return false
      end
    end

    def max_mind_results_for_ip
      @max_mind_results = @ip_service.get_max_mind_info(@validator_ip.address)
    end

    def data_center_from_max_mind_data
      @data_center = @ip_service.set_data_center(@max_mind_results)
      @ip_service.fill_blank_values(@data_center, @max_mind_results)
    end

    def create_or_update_data_center
      @data_center_exists = @data_center.id.present?

      @data_center.save!

      if @data_center_exists
        message = <<-EOS
          Data center already exists (##{@data_center.id}), 
          overridden by actual data from max_mind.
        EOS

        log_message(message)
      else
        message = <<-EOS
          New data center #{@data_center.data_center_key} 
          created (##{@data_center.id}) from max_mind data.
        EOS

        log_message(message)
      end
    end

    def assign_validator_to_new_data_center
      # If data center from max_mind is the same as already assigned - do nothing, it's ok.
      if @data_center.id == @validator&.data_center&.id
        message = <<-EOS
          Data center from max_mind is the same that is assigned to validator, no need to re-assign.
        EOS

        log_message(message)
        log_message(SEPARATOR)

        return nil
      end

      # If data_center_host is assigned only to one validator 
      # then we can change data center with no impact on other validators.
      if @data_center_host.present? && @data_center_host.validators.size == 1
        @data_center_host.update!(data_center: @data_center)

        message = <<-EOS
          Existing data center host (##{@data_center_host.id}) of validator #{@validator.name} (##{@validator.id}) 
          with ip address #{@validator_ip.address} (##{@validator_ip.id}) has been assigned to 
          data center #{@data_center.data_center_key} (##{@data_center.id}).
        EOS

        log_message(message)
      else
        new_dch = DataCenterHost.find_or_create_by!(data_center: @data_center, host: nil)

        @validator_ip.update!(data_center_host: new_dch)

        message = <<-EOS
          Validator #{@validator.name} (##{@validator.id}) and ip address #{@validator_ip.address} 
          has been assigned to data center #{@data_center.data_center_key} 
          (##{@data_center.id}) through new data center host (##{new_dch.id}).
        EOS

        log_message(message)
      end

      @update_score = true
    end

    def log_message(message, type: :info)
      # Remove unless clause to see log file from tests.
      @logger.send(type, message.squish) unless Rails.env.test?
    end
  end
end
