# frozen_string_literal: true

# == Schema Information
#
# Table name: ping_thing_stat_archives
#
#  id                   :bigint           not null, primary key
#  average_slot_latency :integer
#  interval             :integer
#  max                  :float(24)
#  median               :float(24)
#  min                  :float(24)
#  network              :string(191)
#  num_of_records       :integer
#  time_from            :datetime
#  tps                  :integer
#  transactions_count   :bigint
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
class PingThingStatArchive < ApplicationRecord
  # Your model code goes here
end
