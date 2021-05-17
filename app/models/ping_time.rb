# == Schema Information
#
# Table name: ping_times
#
#  id           :bigint           not null, primary key
#  avg_ms       :decimal(10, 3)
#  batch_uuid   :string(255)
#  from_account :string(255)
#  from_ip      :string(255)
#  max_ms       :decimal(10, 3)
#  mdev         :decimal(10, 3)
#  min_ms       :decimal(10, 3)
#  network      :string(255)
#  observed_at  :datetime
#  to_account   :string(255)
#  to_ip        :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_ping_times_on_network_and_batch_uuid                        (network,batch_uuid)
#  index_ping_times_on_network_and_from_account_and_created_at       (network,from_account,created_at)
#  index_ping_times_on_network_and_from_ip_and_created_at            (network,from_ip,created_at)
#  index_ping_times_on_network_and_from_ip_and_to_ip_and_created_at  (network,from_ip,to_ip,created_at)
#  index_ping_times_on_network_and_to_account_and_created_at         (network,to_account,created_at)
#  index_ping_times_on_network_and_to_ip_and_created_at              (network,to_ip,created_at)
#  index_ping_times_on_network_and_to_ip_and_from_ip_and_created_at  (network,to_ip,from_ip,created_at)
#  ndx_network_from_to_account                                       (network,from_account,to_account,created_at)
#  ndx_network_to_from_account                                       (network,to_account,from_account,created_at)
#
class PingTime < ApplicationRecord
end
