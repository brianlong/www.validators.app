# frozen_string_literal: true

module DataCenters
  class ChangeValidatorDataCenter
    LOG_PATH = Rails.root.join("log", "change_validator_data_center.log")
    SEPARATOR = "-" * 50

    def initialize(validator_id, max_mind_client: MaxMindClient)
      @validator_id = validator_id

      @validator = nil
      @validator_ip = nil
      @data_center_host = nil
      @data_center = nil
      @data_center_exists = nil
      @max_mind_results = nil
      @update_score = false

      @max_mind_client = max_mind_client
      @logger ||= Logger.new(LOG_PATH)
    end

    def call
      find_validator
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

      # This step needs to be removed after removing data_center_key from validator_score_v1
      update_data_center_host_in_score if @update_score
    end

    private

    def find_validator
      @validator = Validator.find_by(id: @validator_id)

      if @validator
        log_message("Validator #{@validator.name} (##{@validator.id}) found.")
      else
        log_message(
          "Validator with id: #{@validator_id} has not been found, script is finished.",
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
      @max_mind_results = @max_mind_client.new.insights(@validator_ip.address)
    end

    def data_center_from_max_mind_data
      @data_center = DataCenter.find_or_initialize_by(
        continent_code: @max_mind_results.continent.code,
        continent_geoname_id: @max_mind_results.continent.geoname_id,
        continent_name: @max_mind_results.continent.name,
        country_iso_code: @max_mind_results.country.iso_code,
        country_geoname_id: @max_mind_results.country.geoname_id,
        country_name: @max_mind_results.country.name,
        registered_country_iso_code: @max_mind_results.registered_country.iso_code,
        registered_country_geoname_id: @max_mind_results.registered_country.geoname_id,
        registered_country_name: @max_mind_results.registered_country.name,
        traits_anonymous: @max_mind_results.traits.anonymous?,
        traits_hosting_provider: @max_mind_results.traits.hosting_provider?,
        traits_user_type: @max_mind_results.traits.user_type,
        traits_autonomous_system_number: @max_mind_results.traits.autonomous_system_number,
        traits_autonomous_system_organization: @max_mind_results.traits.autonomous_system_organization,
        city_name: @max_mind_results.city.name,
        location_metro_code: @max_mind_results.location.metro_code,
        location_time_zone: @max_mind_results.location.time_zone,
      )

      @data_center.tap do |dc|
        dc.city_confidence = @max_mind_results.city.confidence
        dc.city_geoname_id = @max_mind_results.city.geoname_id
        dc.country_confidence = @max_mind_results.country.confidence
        dc.location_accuracy_radius = @max_mind_results.location.accuracy_radius
        dc.location_average_income = @max_mind_results.location.average_income
        dc.location_latitude = @max_mind_results.location.latitude
        dc.location_longitude = @max_mind_results.location.longitude
        dc.location_population_density = @max_mind_results.location.population_density
        dc.postal_code = @max_mind_results.postal.code
        dc.postal_confidence = @max_mind_results.postal.confidence
        dc.traits_isp = @max_mind_results.traits.isp
        dc.traits_organization = @max_mind_results.traits.organization
    
        unless @max_mind_results.most_specific_subdivision.nil?
          dc.subdivision_confidence = @max_mind_results.most_specific_subdivision.confidence
          dc.subdivision_iso_code = @max_mind_results.most_specific_subdivision.iso_code
          dc.subdivision_geoname_id = @max_mind_results.most_specific_subdivision.geoname_id
          dc.subdivision_name = @max_mind_results.most_specific_subdivision.name
        end
      end
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
      if @data_center_host.validators.size == 1 
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
          (##{@data_center.id}) through data center host  (##{new_dch.id}).
        EOS

        log_message(message)
      end

      @update_score = true
    end

    def update_data_center_host_in_score
      validator_score = @validator.validator_score_v1
      old_data_center_key = validator_score.data_center_key

      # There is no need to update data_center_key if it remained the same
      if old_data_center_key == @data_center.data_center_key
        log_message(SEPARATOR)
        return nil
      end
        
      validator_score.update!(data_center_key: @data_center.data_center_key)

      message = <<-EOS
        Validator Score V1 of validator #{@validator.name} 
        has been updated from #{old_data_center_key} to #{validator_score.data_center_key}.
      EOS

      log_message(message)
      log_message(SEPARATOR)
    end

    def log_message(message, type: :info)
      # Remove unless clause to see log file from tests.
      @logger.send(type, message.squish) unless Rails.env.test?
    end
  end
end
