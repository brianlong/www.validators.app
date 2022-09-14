class ApplicationMailer < ActionMailer::Base
  helper(EmailHelper)
  
  default from: 'customer.service@fmadata.com'
  layout 'mailer'
end
