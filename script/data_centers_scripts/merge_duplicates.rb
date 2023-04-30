# frozen_string_literal: true
# 
# WARNING: Run script with "yes" argument and you'll update, 
# without you'll get only logs and see what will be updated.
# 
# RAILS_ENV=production bundle exec ruby script/data_centers_scripts/merge_duplicates.rb

require_relative '../../config/environment'

perform_update = ARGV[0] == "yes" ? true : false

DataCenters::MergeDuplicates.new(perform_update: perform_update).call
