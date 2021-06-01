# frozen_string_literal: true

# Extract the base attributes
json.extract! validator,
              :network, :account, :name, :keybase_id, :www_url,
              :details, :created_at, :updated_at

# TODO: fix it because we're missing scores and ips from index API endpoint
# This json partial is used not only for the show page but for the index page as well.
# HOTFIX
@score ||= validator.score
unless @score.nil?
  json.total_score @score.total_score
  json.root_distance_score @score.root_distance_score
  json.vote_distance_score @score.vote_distance_score
  json.skipped_slot_score @score.skipped_slot_score
  json.software_version @score.software_version
  json.software_version_score @score.software_version_score
  json.stake_concentration_score @score.stake_concentration_score
  json.data_center_concentration_score @score.data_center_concentration_score
  json.published_information_score @score.published_information_score
  json.security_report_score @score.security_report_score
  json.active_stake @score.active_stake
  json.commission @score.commission
  json.delinquent @score.delinquent
  json.data_center_key @score.data_center_key
  json.data_center_host @score.data_center_host
  unless @ip.nil?
    json.autonomous_system_number @ip.traits_autonomous_system_number
  end
end

# Vote account data
vote_account = validator.vote_accounts.last
unless vote_account.nil?
  json.vote_account vote_account.account

  # vote_account_history = vote_account.vote_account_histories.last
  # json.software_version vote_account_history.software_version \
  #   unless vote_account_history.nil?
end

# Data from the skipped_slots_report
unless @skipped_slots_report.nil?
  this_report = @skipped_slots_report.payload.select do |ssr|
    ssr['account'] == validator.account
  end

  unless this_report.first.nil?
    json.skipped_slots this_report.first['skipped_slots']
    json.skipped_slot_percent this_report.first['skipped_slot_percent']
    json.ping_time nil # this_report.first['ping_time']
  end
end

# Show URl to this record in the API
json.url api_v1_validator_url(
  network: params[:network],
  account: validator.account,
  format: :json
)
