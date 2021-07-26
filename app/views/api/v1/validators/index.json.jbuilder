# frozen_string_literal: true

# json.array! @validators, partial: 'api/v1/validators/validator', as: :validator

json.array! @validators do |validator|
  json.merge! validator.to_builder.attributes!

  score = validator.score
  ip = score.ip_for_api if score
  vote_account = validator.vote_accounts.last

  json.merge! score.to_builder.attributes!
  json.merge! ip.to_builder.attributes! unless ip.blank?
  json.merge! vote_account.to_builder.attributes! unless vote_account.blank?

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

  json.url validator.api_url
end
