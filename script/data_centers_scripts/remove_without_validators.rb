# frozen_string_literal: true

# WARNING: Run script with "yes" argument and you'll destroy data centers, 
# without you'll get only logs and see what will be destroyed.
# 
# RAILS_ENV=production bundle exec ruby script/data_centers_scripts/remove_duplicates_without_validators.rb

require_relative '../../config/environment'

run_destroy = ARGV[0]
DataCenters::RemoveWithoutValidators.new(run_destroy: run_destroy).call