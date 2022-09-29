# == Schema Information
#
# Table name: ipables
#
#  id          :bigint           not null, primary key
#  ipable_type :string(191)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  ip_id       :bigint
#  ipable_id   :bigint
#
class Ipable < ApplicationRecord
  belongs_to :validator, optional: true
  belongs_to :gossip_node, optional: true 
  belongs_to :validator_ip, foreign_key: :ip, class_name: "ValidatorIp"
end
