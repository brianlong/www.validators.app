# frozen_string_literal: true

# RAILS_ENV=production bundle exec ruby script/create_home_page_chart.rb
require File.expand_path('../config/environment', __dir__)
require 'solana_logic'
require 'report_logic'

include SolanaLogic
include ReportLogic

# Create our initial payload with the input values
payload = {
  network: 'testnet',
  epoch: 61,
  name: 'chart_home_page'
}

results = Pipeline.new(200, payload).then(&chart_home_page)

puts results
