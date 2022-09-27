# frozen_string_literal: true
#
# RAILS_ENV=production bundle exec rails r script/validator_ips/remove_without_validator_or_gossip_node.rb [yes]

require_relative '../../config/environment'

run_destroy = ARGV[0]

puts "Validator Ips before removal: #{ValidatorIp.count}"
validator_ips_without_validator_and_gossip_node = ValidatorIp.where.missing(:validator, :gossip_node)
puts "Validator Ips to remove: #{validator_ips_without_validator_and_gossip_node.size}"

if run_destroy == "yes"
  validator_ips_without_validator_and_gossip_node.destroy_all
  puts "Validator Ips after removal: #{ValidatorIp.count}"
end
