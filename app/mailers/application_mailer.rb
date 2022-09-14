# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "customer.service@fmadata.com"
  layout "mailer"
end
