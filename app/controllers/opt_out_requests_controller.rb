class OptOutRequestsController < ApplicationController
  def index
    if current_user&.is_admin?
      @opt_out_requests = OptOutRequest.order('created_at desc')
                                       .page(params[:page])
                                       .per(25)
    else
      flash[:warning] = 'You are not allowed to enter this page.'
      redirect_to :root
    end
  end

  def new
    @opt_out_request = OptOutRequest.new
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "new"
      end
    end
  end

  def create
    browser = Browser.new(request.env['HTTP_USER_AGENT'])
    @opt_out_request = OptOutRequest.new(
      opt_out_request_params.merge(
        meta_data: {
          ip: request.remote_ip,
          referer: request.referrer,
          device: browser.device.name,
          platform: browser.platform.name,
          bot: browser.bot?,
          bot_reason: browser.bot.why?
        }
      )
    )

    if browser.bot? && !Rails.env.test?
      flash[:error] = 'Bots are not allowed on this page.'
      render :new
    elsif verify_recaptcha(model: @opt_out_request) && @opt_out_request.valid? && @opt_out_request.save
      #ContactRequestMailer.new_opt_out_request_notice(@opt_out_request.id).deliver_now
      redirect_to thank_you_opt_out_requests_path
    else
      render :new
    end
  end

  def thank_you; end

  def destroy
    if current_user&.is_admin?
      @opt_out_request = OptOutRequest.find(params[:id])
      @opt_out_request.destroy
      flash[:notice] = 'Request has been destroyed.'
      redirect_to opt_out_requests_path
    else
      flash[:warning] = 'You are not allowed to enter this page.'
      redirect_to :root
    end
  end

  private

  def opt_out_request_params
    params.require(:opt_out_request)
          .permit(
            :request_type,
            :name,
            :street_address,
            :city,
            :postal_code,
            :state,
            :meta_data
          )
  end
end
