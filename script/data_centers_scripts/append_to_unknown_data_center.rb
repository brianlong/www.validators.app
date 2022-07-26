# frozen_string_literal: true

# RAILS_ENV=production bundle exec ruby script/data_centers_scripts/append_to_unknown_data_center.rb
require_relative '../../config/environment'
log_path = Rails.root.join('log', 'append_to_unknown_data_center.log')
@logger ||= Logger.new(log_path)

@logger.info "Script has started at #{Time.now}"

begin
  # Data center for validators without data_center assigned
  # most cases does not provide IP so we cannot assign them
  # because we cannot check their IP in MaxMind. 
  unknown_data_center = DataCenter.find_by(data_center_key: 'Unknown')
  data_center_host = unknown_data_center.data_center_hosts.find_by(host: nil)

  validators_active_without_data_center = Validator.active.where.missing(:data_center)

  validators_active_without_data_center.each do |val|
    # Probably waiting for script append_data_centers_geo_data.rb
    # which is fired every 1 hour
    if val.validator_ips.any?
      next
    else
      validator_ip = val.validator_ips.create(
        data_center_host: data_center_host,
        address: nil, 
        is_active: true
      )

      info = <<-EOS 
        Validator #{val.name} (##{val.id}) assigned to 
        data center: #{unknown_data_center.data_center_key} (##{unknown_data_center.id})
      EOS

      @logger.info info.squish
    end
  end

  @logger.info "Script has finished at #{Time.now}"
end