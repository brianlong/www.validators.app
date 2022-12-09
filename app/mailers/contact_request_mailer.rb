class ContactRequestMailer < ApplicationMailer
  def new_contact_request_notice(admins)
    return nil unless admins.any?

    admins.each do |admin|
      mail(to: admin.email, subject: 'New contact request')
    end
  end

  def new_opt_out_request_notice(request_id)
    @opt_out_request = OptOutRequest.find(request_id)
    mail(to: ADMIN_EMAIL,
         cc: BRIAN_EMAIL,
         subject: "New opt-out request on www.validators.app")
  end
end
