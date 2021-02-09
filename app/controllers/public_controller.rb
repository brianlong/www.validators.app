# frozen_string_literal: true

# PublicController
class PublicController < ApplicationController
  def index
    @sort_order = if params[:order] == 'score'
                    'validator_score_v1s.total_score desc,  validator_score_v1s.active_stake desc'
                  elsif params[:order] == 'name'
                    'validators.name asc'
                  elsif params[:order] == 'stake'
                    'validator_score_v1s.active_stake desc, validator_score_v1s.total_score desc'
                  elsif params[:order] == 'random'
                    'RAND()'
                  else
                    'validator_score_v1s.total_score desc,  validator_score_v1s.active_stake desc'
                  end

    @validators = Validator.where(network: params[:network])
                           .joins(:validator_score_v1)
                           .order(@sort_order)
                           .page(params[:page])

    unless params[:q].blank?
      @validators = @validators.where(
        ['name like :q or account like :q or validator_score_v1s.data_center_key like :q', q: "#{params[:q]}%"]
      )
    end

    @total_active_stake = Validator.where(network: params[:network])
                                   .joins(:validator_score_v1)
                                   .sum(:active_stake)

    @software_versions = Report.where(
      network: params[:network],
      name: 'report_software_versions'
    ).last

    @batch = Batch.where(network: params[:network]).last
    @batch_previous = Batch.where(network: params[:network])
                           .order('id desc')
                           .limit(2)[1]
    batch_previous_uuid = @batch_previous&.uuid || 'no-uuid'

    if @batch
      @this_epoch = EpochHistory.where(
        network: params[:network],
        batch_uuid: @batch.uuid
      ).first
      @tower_highest_block = ValidatorHistory.highest_root_block_for(
        params[:network],
        @batch.uuid
      )
      @tower_highest_vote = ValidatorHistory.highest_last_vote_for(
        params[:network],
        @batch.uuid
      )
      @skipped_slot_average = \
        ValidatorBlockHistory.average_skipped_slot_percent_for(
          params[:network],
          batch_previous_uuid
        )
      @skipped_slot_median = \
        ValidatorBlockHistory.median_skipped_slot_percent_for(
          params[:network],
          batch_previous_uuid
        )
    end

    # Calculate the best skipped vote percent.
    @credits_current_max = VoteAccountHistory.where(
      network: params[:network],
      batch_uuid: batch_previous_uuid
    ).maximum(:credits_current).to_i
    @slot_index_current = VoteAccountHistory.where(
      network: params[:network],
      batch_uuid: batch_previous_uuid
    ).maximum(:slot_index_current).to_i
    @skipped_vote_percent_best = \
      (@slot_index_current - @credits_current_max )/@slot_index_current.to_f

    # Ping Times
    ping_batch = PingTime.where(network: params[:network])&.last&.batch_uuid
    ping_time_stat = PingTimeStat.where(batch_uuid: ping_batch)&.last
    @ping_time_avg = ping_time_stat&.overall_average_time

    # flash[:error] = 'Due to an issue with our RPC server pool, the Skipped Slot % data may be inaccurate. I am aware of the problem and working on a solution. Thanks! -- Brian Long'

    render 'validators/index'
  end

  def tower
    @title = "Solana #{params[:network].capitalize} Tower"

    @tower_report = Report.where(
      network: params[:network],
      name: 'report_tower_height'
    ).last

    @show_full_account = true

    @tower_leaders = if @tower_report.nil?
                       []
                     else
                       @tower_report.payload
                     end
  end

  def api_documentation
    @title = 'API Documentation'
  end

  def cookie_policy
    @title = t('public.cookie_policy.title')
  end

  def do_not_sell_my_personal_information; end

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

  def contact_us
    if request.post?
      @contact_request = ContactRequest.new(contact_us_params)
      if @contact_request.save
        flash[:notice] = t('public.contact_us.flash.contact_request_saved')
        send_email_to_admins_about_new_request
      else
        render 'contact_us'
      end
    else
      @contact_request = ContactRequest.new
    end
    @title = t('public.contact_us.title')
  end

  private

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
