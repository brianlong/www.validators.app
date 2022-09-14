# frozen_string_literal: true

class CommissionHistoryMailer < ApplicationMailer
  def commission_change_info(validator:, commission: )
    @validator = validator
    @validator_title = validator_title(@validator)
    @commission = commission

    watchers = @validator.watchers

    return nil unless watchers.any?

    watchers.each do |watcher|
      mail(to: watcher.email, subject: "Validator commission changed")
    end
  end

  private

  def validator_title(validator)
    validator.name || validator.account
  end
end
