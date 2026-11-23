# frozen_string_literal: true

class CommissionHistoryMailer < ApplicationMailer
  def commission_change_info
    user = params[:user]
    @validator = params[:validator]
    @validator_title = validator_title(@validator)
    @commission = params[:commission]

    raise "invalid user" unless @validator.watchers.include? user
    
    mail(to: user.email, subject: "Validator commission changed")
  end

  private

  def validator_title(validator)
    validator.name || validator.account
  end
end
