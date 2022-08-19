# frozen_string_literal: true

# RAILS_ENV=production bundle exec ruby script/fill_skipped_slot_all_average_in_batches.rb

require_relative '../../config/environment'

ASN = 23470

# ValidatorIp.joins(:data_center)
#            .includes(:validator)
#            .where(
#               "is_active = ? AND is_overridden = ? AND data_centers.traits_autonomous_system_number = ?", 
#               true, false, ASN
#             ).each do |vip|
ValidatorIp.joins(:data_center).includes(:validator).where("is_active = ? AND data_centers.traits_autonomous_system_number = ?", true, ASN).each do |vip|
  service = DataCenters::ChangeValidatorDataCenter.new(vip.validator.id).call
end

ValidatorIp.joins(:data_center).includes(:validator).where("is_active = ? AND data_centers.traits_autonomous_system_number = ?", true, ASN)