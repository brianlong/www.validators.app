# frozen_string_literal: true

# RAILS_ENV=production bundle exec ruby script/data_centers_scripts/change_validator_data_center.rb

require_relative '../../config/environment'

validator_id = ARGV[0]

unless validator_id
  puts "ERROR: Please provide validator id as an argument."
  return false
end

DataCenters::ChangeValidatorDataCenter.new(ARGV[0]).call
