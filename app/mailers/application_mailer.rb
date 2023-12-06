# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "hello@blocklogic.net"
  layout "mailer"
end
