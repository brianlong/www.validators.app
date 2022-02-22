# == Schema Information
#
# Table name: data_center_hosts
#
#  id             :bigint           not null, primary key
#  host           :string(191)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  data_center_id :bigint
#
# Indexes
#
#  index_data_center_hosts_on_data_center_id  (data_center_id)
#
class DataCenterHost < ApplicationRecord
end
