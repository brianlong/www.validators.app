class ContactRequestsController < ApplicationController
  before_action :authenticate_user!, only: [:index]

  def index
    if current_user&.is_admin?
      @contact_requests = ContactRequest.order('id desc').all
    else
      flash[:warning] = t('public.contact_us.flash.only_admins_allowed')
      redirect_to :root
    end
  end
end
