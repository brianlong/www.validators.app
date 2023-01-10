# frozen_string_literal: true

# RAILS_ENV=production bundle exec rails r script/one_time_scripts/set_is_active_in_validator_ips.rb

require_relative '../../config/environment'
log_path = Rails.root.join('log', 'set_is_active_in_validator_ips.log')
@logger ||= Logger.new(log_path)

Validator.find_each do |validator|
  vips = validator.validator_ips.order('updated_at desc')

  most_recent_updated_validator_ip = vips.first

  next unless most_recent_updated_validator_ip
  next if most_recent_updated_validator_ip.is_active

  most_recent_updated_validator_ip.update(is_active: true)

  @logger.info("Validator's #{validator.name} (id: #{validator.id}) active ip is now #{most_recent_updated_validator_ip.address} with id #{most_recent_updated_validator_ip.id}")
end
