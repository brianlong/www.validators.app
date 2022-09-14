# frozen_string_literal: true

class CommissionHistoryMailer < ApplicationMailer
  def commission_change_info(user:, validator:, commission: )
    @validator = validator
    @validator_title = validator_title(@validator)
    @commission = commission

    raise "invalid user" unless @validator.watchers.include? user
    
    mail(to: user.email, subject: "Validator commission changed")
  end

  private

  def validator_title(validator)
    validator.name || validator.account
  end
end
