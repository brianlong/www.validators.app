# frozen_string_literal: true

# == Schema Information
#
# Table name: ping_thing_raws
#
#  id         :bigint           not null, primary key
#  api_token  :string(191)
#  network    :string(191)
#  raw_data   :text(65535)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class PingThingRaw < ApplicationRecord

  validate :raw_data_size

  def attributes_from_raw
    params = JSON.parse(raw_data).symbolize_keys
    reported_at = params[:reported_at].to_datetime rescue DateTime.now

    # params that are required by ping_thing model to be present
    required_params = {
      response_time: params[:time].to_i,
      signature: params[:signature],
      network: params[:network],
      reported_at: reported_at
    }

    # optional params
    optional_params = {}
    optional_params[:amount] = params[:amount].to_i if params[:amount].present?
    optional_params[:application] = params[:application] if params[:application].present?
    optional_params[:commitment_level] = params[:commitment_level] if params[:commitment_level].present?
    optional_params[:success] = params[:success] if params[:success].present? || params[:success] == false
    optional_params[:transaction_type] = params[:transaction_type] if params[:transaction_type].present?
    optional_params[:slot_sent] = params[:slot_sent].to_i \
      if params[:slot_sent].present? && slot_valid?(params[:slot_sent])
    optional_params[:slot_landed] = params[:slot_landed].to_i \
      if params[:slot_landed].present? && slot_valid?(params[:slot_landed])

    required_params.merge(optional_params)
  end

  def should_recalculate_stats_after_processing?
    JSON.parse(raw_data).keys.include?("reported_at")
  end

  private

  def raw_data_size
    errors.add :base, "Provided data length is not valid" \
      unless raw_data.size.between? 20, 350
  end

  def slot_valid?(slot)
    slot&.to_i > 0
  end
end
