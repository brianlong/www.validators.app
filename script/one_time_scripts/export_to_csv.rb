# frozen_string_literal: true

# Use this script to export data to CSV in special cases.
#
# RAILS_ENV=production bundle exec ruby script/export_to_csv.rb
require File.expand_path('../../config/environment', __dir__)
require 'csv'

out_file = '/tmp/validators_export.csv'

# sql = "select id as vote_account_id, validator_id, account as vote_account, created_at, updated_at from vote_accounts where validator_id in (select validator_id from vote_accounts where network = 'mainnet' and updated_at >= '2023-01-29%' group by validator_id having count(validator_id) > 1) and updated_at >= '2023-01-29%' order by validator_id, created_at;"
sql = "select * from account_authority_histories"
records = ActiveRecord::Base.connection.execute(sql)

CSV.open(out_file, 'w') do |csv|
  csv << records.fields
  records.each do |r|
    csv << r
  end  
end
