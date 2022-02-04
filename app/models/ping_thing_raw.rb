# == Schema Information
#
# Table name: ping_thing_raws
#
#  id         :bigint           not null, primary key
#  raw_data   :text(65535)
#  token      :string(191)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class PingThingRaw < ApplicationRecord
end
