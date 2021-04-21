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
                    params[:order] = 'score'
                    'validator_score_v1s.total_score desc, validator_score_v1s.active_stake desc'
                  end

    validators = Validator.where(network: params[:network])
                          .joins(:validator_score_v1)
                          .order(@sort_order)
    @validators_count = validators.count
    @validators = validators.page(params[:page])

    unless params[:q].blank?
      @validators = @validators.where(
        ['name like :q or account like :q or validator_score_v1s.data_center_key like :q', q: "#{params[:q]}%"]
      )
    end

    @total_active_stake = Validator.where(network: params[:network])
                                   .joins(:validator_score_v1)
                                   .sum(:active_stake)

    active_stakes = validators.pluck(:active_stake).compact
    @at_33_stake = active_stakes.inject do |s, v|
      if (s / @total_active_stake.to_f) >= 0.33
        break active_stakes.index(v)
      end
      s + v
    end

    @software_versions = Report.where(
      network: params[:network],
      name: 'report_software_versions'
    ).last

    @batch = Batch.where(
      ["network = ? AND scored_at IS NOT NULL",  params[:network]]
    ).last

    if @batch
      @this_epoch = EpochHistory.where(
        network: params[:network],
        batch_uuid: @batch.uuid
      ).first
      @skipped_slot_average = \
        ValidatorBlockHistory.average_skipped_slot_percent_for(
          params[:network],
          @batch.uuid
        )
      @skipped_slot_median = \
        ValidatorBlockHistory.median_skipped_slot_percent_for(
          params[:network],
          @batch.uuid
        )

      # Calculate the best skipped vote percent.
      @credits_current_max = VoteAccountHistory.where(
        network: params[:network],
        batch_uuid: @batch.uuid
      ).maximum(:credits_current).to_i
      @slot_index_current = VoteAccountHistory.where(
        network: params[:network],
        batch_uuid: @batch.uuid
      ).maximum(:slot_index_current).to_i
      @skipped_vote_percent_best = \
        (@slot_index_current - @credits_current_max )/@slot_index_current.to_f

    end

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

  def stake_boss
    @title = t('public.stake_boss.title')
  end

  def contact_us
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
