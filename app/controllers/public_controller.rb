# frozen_string_literal: true

# PublicController
class PublicController < ApplicationController
  def index
    @block_history_stat = ValidatorBlockHistoryStat.last || ValidatorBlockHistoryStat.new

    @chart_data = Report.where(
      network: 'testnet',
      name: 'chart_home_page'
    ).last

    @skipped_slots_report = Report.where(
      network: 'testnet',
      name: 'build_skipped_slot_percent'
    ).last

    @skipped_slots_top = if @skipped_slots_report.nil?
                           []
                         else
                           @skipped_slots_report.payload[0..19]
                         end

    @skipped_slots_bottom = if @skipped_slots_report.nil? ||
                               @skipped_slots_report.payload.nil?
                              []
                            else
                              begin
                                @skipped_slots_report.payload[-20..-1].reverse
                              rescue StandardError
                                []
                              end
                            end

    @skipped_after_report = Report.where(
      network: 'testnet',
      name: 'build_skipped_after_percent'
    ).last

    @skipped_after_top = if @skipped_after_report.nil?
                           []
                         else
                           @skipped_after_report.payload[0..19]
                         end
    @skipped_after_bottom = if @skipped_after_report.nil?
                              []
                            else
                              @skipped_after_report.payload[-20..-1]
                                                   .try(:reverse)
                            end

    # Report Tower Height
    @tower_report = Report.where(
      network: 'testnet',
      name: 'report_tower_height'
    ).last

    @tower_leaders = if @tower_report.nil?
                       []
                     else
                       @tower_report.payload[0..19]
                     end

    @tower_laggards = if @tower_report.nil?
                        []
                      else
                        @tower_report.payload[-20..-1]
                                     .try(:reverse)
                      end
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
