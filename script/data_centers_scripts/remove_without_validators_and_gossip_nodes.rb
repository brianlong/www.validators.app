# frozen_string_literal: true

# RAILS_ENV=production bundle exec ruby script/data_centers_scripts/change_validator_data_center.rb validator_id

require_relative '../../config/environment'


DataCenters::RemoveWithoutValidatorsAndGossipNodes.new.call