# frozen_string_literal: true

# PublicController
class PublicController < ApplicationController
  # GET /
  def home
    @network = home_params[:network]
  end

  def api_documentation
    @title = 'API Documentation'
    @low_limit = Rack::Attack::API_LOW_LIMIT
    @high_limit = Rack::Attack::API_HIGH_LIMIT
    @reset_period = Rack::Attack::LIMIT_RESET_PERIOD.seconds.in_minutes.round
    @api_path = case Rails.env
                when "stage", "staging"
                  "https://stage.validators.app/api/v1"
                when "production"
                  "https://validators.app/api/v1"
                else
                  "http://localhost:#{request.port}/api/v1"
                end
  end

  def cookie_policy
    @title = t('public.cookie_policy.title')
  end

  def faq
    @title = t('public.faq.title')
  end

  def terms_of_use
    @title = t('public.terms_of_use.title')
  end

  def privacy_policy
    @title = t('public.privacy_policy.title')
  end

  def privacy_policy_california
    @title = t('public.privacy_policy.title')
  end

  def sample_chart; end

  def stake_boss
    @title = t('public.stake_boss.title')
  end

  def contact_us
    @title = t('public.contact_us.title')
  end

  def commission_histories
    if params[:validator_id]
      begin
        @validator = Validator.find(params[:validator_id])
      rescue ActiveRecord::RecordNotFound
        render_404
      end
    end
  end

  private

  def home_params
    params.permit(:network)
  end

  def validate_order
    valid_orders = %w[score name stake random]
    return 'score' unless params[:order].in? valid_orders

    params[:order]
  end

  def contact_us_params
    params.require(:contact_request)
          .permit(
            :name,
            :email_address,
            :telephone,
            :comments
          )
  end

  def send_email_to_admins_about_new_request
    admins = User.where(is_admin: true)
    ContactRequestMailer.new_contact_request_notice(admins).deliver_now
  end
end
