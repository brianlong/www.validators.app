# frozen_string_literal: true

module ValidatorsControllerHelper
  def create_json_result(validator, with_history = false)
    hash = {}

    hash.merge!(validator.to_builder.attributes!)

    score = validator.score
    ip = score.ip_for_api if score
    vote_account = validator.vote_accounts.last
    validator_history = validator.most_recent_epoch_credits_by_account

    
    hash.merge!(score.to_builder(with_history: with_history).attributes!)
    hash.merge!(ip.to_builder.attributes!) unless ip.blank?
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
    [
      "account",
      "created_at",
      "details",
      "id",
      "keybase_id",
      "name",
      "network",
      "updated_at",
      "www_url",
      "avatar_url",
      "admin_warning"
    ].map { |e| "validators.#{e}" }
  end

  def validator_score_v1_fields
    [
      "active_stake",
      "commission",
      "delinquent",
      "data_center_concentration_score",
      "data_center_key",
      "data_center_host",
      "published_information_score",
      "root_distance_score",
      "security_report_score",
      "skipped_slot_score",
      "software_version",
      "software_version_score",
      "stake_concentration_score",
      "total_score",
      "validator_id",
      "vote_distance_score"
    ].map { |e| "validator_score_v1s.#{e}" }
  end
end
