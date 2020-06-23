# frozen_string_literal: true

# Extract the base attributes
json.extract! validator,
              :network, :account, :name, :keybase_id, :www_url, :created_at,
              :updated_at

# Vote account data
vote_account = validator.vote_accounts.last
unless vote_account.nil?
  json.vote_account vote_account.account

  vote_account_history = vote_account.vote_account_histories.last
  json.software_version vote_account_history.software_version \
    unless vote_account_history.nil?
end

# Data from the skipped_slots_report
unless @skipped_slots_report.nil?
  this_report = @skipped_slots_report.payload.select do |ssr|
    ssr['account'] == validator.account
  end

  unless this_report.first.nil?
    json.skipped_slots this_report.first['skipped_slots']
    json.skipped_slot_percent this_report.first['skipped_slot_percent']
    json.ping_time this_report.first['ping_time']
  end
end

# Data from the skipped_after_report
unless @skipped_after_report.nil?
  this_after_report = @skipped_after_report.payload.select do |sar|
    sar['account'] == validator.account
  end

  unless this_after_report.first.nil?
    json.skipped_slots_after this_after_report.first['skipped_slots_after']
    json.skipped_slots_after_percent \
      this_after_report.first['skipped_slots_after_percent']
  end
end

# Show URl to this record in the API
json.url api_v1_validator_url(
  network: params[:network],
  account: validator.account,
  format: :json
)
