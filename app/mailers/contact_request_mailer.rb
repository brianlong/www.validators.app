class ContactRequestMailer < ApplicationMailer
  def new_contact_request_notice(admins)
    return nil unless admins.any?
    
    admins.each do |admin|
      mail(to: admin.email, subject: 'New contact request')
    end
  end
end
