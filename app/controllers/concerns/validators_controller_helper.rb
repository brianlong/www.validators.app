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

  def index_csv_headers(with_history)
    headers = Validator::FIELDS_FOR_API + 
              ValidatorScoreV1::ATTRIBUTES_FOR_BUILDER + 
              DataCenter::FIELDS_FOR_CSV + 
              [:data_center_host] + 
              [:vote_account] +
              ValidatorHistory::FIELDS_FOR_CSV
    headers += ValidatorScoreV1::HISTORY_FIELDS if with_history
    headers.map(&:to_s)
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
end
