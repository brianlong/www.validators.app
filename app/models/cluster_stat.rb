# frozen_string_literal: true

# == Schema Information
#
# Table name: cluster_stats
#
#  id                 :bigint           not null, primary key
#  network            :string(191)
#  total_active_stake :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
class ClusterStat < ApplicationRecord

  def broadcast
    ActionCable.server.broadcast("cluster_stat_channel", self.to_json)
  end
end
