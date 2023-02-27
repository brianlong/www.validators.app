# frozen_string_literal: true

module ValidatorsControllerHelper
  def create_json_result(validator, with_history = false)
    hash = {}

    hash.merge!(validator.to_builder.attributes!)

    validator_score = with_history ? validator.validator_score_v1 : validator.validator_score_v1_for_api

    data_center = validator.validator_ip_active_for_api&.data_center_host_for_api&.data_center_for_api
    data_center_host = validator.validator_ip_active_for_api&.data_center_host_for_api
    vote_account = validator.vote_accounts_for_api.last
    validator_history = validator.most_recent_epoch_credits_by_account

    hash.merge!(validator_score.to_builder(with_history: with_history).attributes!)
    hash.merge!(data_center.to_builder.attributes!) unless data_center.blank?
    hash.merge!(data_center_host.to_builder.attributes!) unless data_center_host.blank?
    hash.merge!(vote_account.to_builder.attributes!) unless vote_account.blank?
    hash.merge!(validator_history.to_builder.attributes!) unless validator_history.blank?
    
    # Data from the skipped_slots_report
    unless @skipped_slots_report.nil?
      this_report = @skipped_slots_report.payload.select do |ssr|
        ssr["account"] == validator.account
      end

      unless this_report.first.nil?
        hash.merge!({
          "skipped_slots" => this_report.first["skipped_slots"],
          "skipped_slot_percent" => this_report.first["skipped_slot_percent"],
          "ping_time" => nil # this_report.first["ping_time"]
        })
      end
    end

    hash.merge!({url: validator.api_url})
    hash
  end

  def validator_fields
    Validator::FIELDS_FOR_API.map { |e| "validators.#{e}" }
  end

  def validator_score_v1_fields_for_api
    ValidatorScoreV1::FIELDS_FOR_API.map { |e| "validator_score_v1s.#{e}" }
  end

  def validator_score_v1_fields_for_validators_index_web
    ValidatorScoreV1::FIELDS_FOR_VALIDATORS_INDEX_WEB.map { |e| "validator_score_v1s.#{e}" }
  end

  def set_boolean_field(value)
    true_values = [true, "true", 1, "1"]

    return true if true_values.include?(value) 
    false 
  end

  def search_with_results_action
    @per = 25

    if validators_params[:watchlist] && !current_user
      flash[:warning] = "You need to create an account first."
      redirect_to new_user_registration_path and return
    end

    watchlist_user = validators_params[:watchlist] ? current_user&.id : nil

    @validators = ValidatorQuery.new(watchlist_user: watchlist_user).call(
      network: validators_params[:network],
      sort_order: validators_params[:order],
      limit: @per,
      page: validators_params[:page],
      query: validators_params[:q],
      admin_warning: validators_params[:admin_warning]
    )

    @batch = Batch.last_scored(validators_params[:network])

    if @batch
      @this_epoch = EpochHistory.where(
        network: validators_params[:network],
        batch_uuid: @batch.uuid
      ).first
    end

    if validators_params[:order] == "stake" && !validators_params[:q] && !validators_params[:watchlist]
      @at_33_stake_index = at_33_stake_index(@validators, @batch, @per)
    end

    @at_33_stake_index ||= nil
  end

  private

  def at_33_stake_index(validators, batch, per_page)
    validator_history_stats = Stats::ValidatorHistory.new(validators_params[:network], batch.uuid)
    at_33_stake_validator = validator_history_stats.at_33_stake&.validator

    return nil unless validators.map(&:account).compact.include? at_33_stake_validator&.account

    first_index_of_current_page = [validators_params[:page].to_i - 1, 0].max * per_page
    first_index_of_current_page + validators.index(at_33_stake_validator).to_i + 1
  end
end
