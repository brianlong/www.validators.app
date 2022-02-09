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

    {
      amount: params[:amount].to_i,
      response_time: params[:time].to_i,
      signature: params[:signature],
      transaction_type: params[:transaction_type]
    }
  end

  private

  def raw_data_size
    errors.add :base, "Provided data length is not valid" \
      unless raw_data.size.between? 20, 300
  end
end
