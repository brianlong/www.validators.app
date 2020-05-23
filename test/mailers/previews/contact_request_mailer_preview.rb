# Preview all emails at http://localhost:3000/rails/mailers/contact_request_mailer
class ContactRequestMailerPreview < ActionMailer::Preview
  def new_contact_request_notice_preview
    # create one if you don't have any
    # User.create(is_admin: true, email: 'test@test.pl', username: 'AdminTest', password: 'password')
    admins = User.where(is_admin: true) 
    ContactRequestMailer.new_contact_request_notice(admins)
  end
end
