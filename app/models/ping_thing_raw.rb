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

  OPTIONAL_PARAMS = %i[amount application commitment_level success transaction_type fee slot_sent slot_landed].freeze

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
    OPTIONAL_PARAMS.each do |opt_param|
      next if [:slot_sent, :slot_landed].include?(opt_param) && !slot_valid?(params[opt_param])
      optional_params[opt_param] = params[opt_param] if params[opt_param].present?
    end

    required_params.merge(optional_params)
  end

  def should_recalculate_stats_after_processing?
    JSON.parse(raw_data).keys.include?("reported_at")
  end

  private

  def raw_data_size
    errors.add :base, "Provided data length is not valid" \
      unless raw_data.size.between? 20, 370
  end

  def slot_valid?(slot)
    slot&.to_i > 0
  end
end
