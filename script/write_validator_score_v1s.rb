# frozen_string_literal: true

# RAILS_ENV=production bundle exec ruby script/write_validator_score_v1s.rb >> /tmp/write_validator_score_v1s.log 2>&1 &

require File.expand_path('../config/environment', __dir__)
require 'csv'

sql = "select v.name, v.account, s.ip_address, s.data_center_key, s.active_stake, s.created_at from validators v inner join validator_score_v1s s on v.id = s.validator_id where v.network = 'mainnet' order by s.created_at;"

CSV.open('/tmp/validator_score_v1s.csv', 'w') do |csv|
  csv << %w[name account ip_address data_center_key active_stake created_at]
  ActiveRecord::Base.connection.execute(sql).each do |row|
    puts row.inspect
    csv << row
  end
end
