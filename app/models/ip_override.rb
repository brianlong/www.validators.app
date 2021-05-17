# == Schema Information
#
# Table name: ip_overrides
#
#  id                                    :bigint           not null, primary key
#  address                               :string(191)
#  city_name                             :string(191)
#  country_iso_code                      :string(191)
#  country_name                          :string(191)
#  data_center_host                      :string(191)
#  data_center_key                       :string(191)
#  traits_autonomous_system_number       :integer
#  traits_autonomous_system_organization :string(191)
#  created_at                            :datetime         not null
#  updated_at                            :datetime         not null
#
# Indexes
#
#  index_ip_overrides_on_address  (address) UNIQUE
#
class IpOverride < ApplicationRecord
end
