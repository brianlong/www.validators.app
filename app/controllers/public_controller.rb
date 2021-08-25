# frozen_string_literal: true

# PublicController
class PublicController < ApplicationController
  def index
    validators = Validator.where(network: index_params[:network])
                          .scorable
                          .joins(:validator_score_v1)
                          .index_order(validate_order)

    @validators_count = validators.size

    unless params[:q].blank?
      validators = ValidatorSearchQuery.new(validators).search(index_params[:q])
    end

    @validators = validators.page(index_params[:page])

    @batch = Batch.last_scored(params[:network])

    @software_versions = Report.find_by(
      network: index_params[:network],
      name: 'report_software_versions',
      batch_uuid: @batch.uuid
    )

    if @batch
      @this_epoch = EpochHistory.where(
        network: index_params[:network],
        batch_uuid: @batch.uuid
      ).first

      validator_block_history_query =
        ValidatorBlockHistoryQuery.new(index_params[:network], @batch.uuid)

      @skipped_slot_average =
        validator_block_history_query.scorable_average_skipped_slot_percent
      @skipped_slot_median =
        validator_block_history_query.median_skipped_slot_percent

      validator_history =
        ValidatorHistoryQuery.new(index_params[:network], @batch.uuid)
      @total_active_stake = validator_history.total_active_stake

      at_33_stake_validator = validator_history.at_33_stake&.validator
      @at_33_stake_index = (validators.index(at_33_stake_validator)&.+ 1).to_i
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
      @validator = Validator.find(params[:validator_id])
    end
  end

  private

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

  def index_params
    params.permit(:network, :order, :page, :q)
  end

  def send_email_to_admins_about_new_request
    admins = User.where(is_admin: true)
    ContactRequestMailer.new_contact_request_notice(admins).deliver_now
  end
end
