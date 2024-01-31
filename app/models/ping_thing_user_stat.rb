#frozen_string_literal: true

# == Schema Information
#
# Table name: ping_thing_user_stats
#
#  id                   :bigint           not null, primary key
#  average_slot_latency :float(24)
#  fails_count          :integer
#  interval             :integer
#  max                  :float(24)
#  median               :float(24)
#  min                  :float(24)
#  network              :string(191)
#  num_of_records       :integer
#  p90                  :float(24)
#  username             :string(191)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  user_id              :bigint           not null
#
# Indexes
#
#  index_ping_thing_user_stats_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class PingThingUserStat < ApplicationRecord
  INTERVALS = [5, 60].freeze #minutes

  validates :network, presence: true
  validates :network, inclusion: { in: NETWORKS }
  validates :interval, presence: true
  validates :interval, inclusion: { in: INTERVALS }
  validates :user_id, presence: true
end
