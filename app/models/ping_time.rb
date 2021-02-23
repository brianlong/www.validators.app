# == Schema Information
#
# Table name: ping_times
#
#  id           :bigint           not null, primary key
#  batch_uuid   :string(255)
#  network      :string(255)
#  from_account :string(255)
#  from_ip      :string(255)
#  to_account   :string(255)
#  to_ip        :string(255)
#  min_ms       :decimal(10, 3)
#  avg_ms       :decimal(10, 3)
#  max_ms       :decimal(10, 3)
#  mdev         :decimal(10, 3)
#  observed_at  :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class PingTime < ApplicationRecord
end
