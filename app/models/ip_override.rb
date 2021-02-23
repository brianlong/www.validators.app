# == Schema Information
#
# Table name: ip_overrides
#
#  id                              :bigint           not null, primary key
#  address                         :string(255)
#  traits_autonomous_system_number :integer
#  country_iso_code                :string(255)
#  country_name                    :string(255)
#  city_name                       :string(255)
#  data_center_key                 :string(255)
#  data_center_host                :string(255)
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#
class IpOverride < ApplicationRecord
end
