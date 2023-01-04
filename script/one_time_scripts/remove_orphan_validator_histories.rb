# frozen_string_literal: true

log_path = File.join(Rails.root, 'log', 'remove_orphan_validator_histories.log')
logger = Logger.new(log_path)

SQL = "DELETE FROM validator_histories vh WHERE (NOT EXISTS (SELECT * FROM validators v WHERE v.account = vh.account AND v.network = vh.network))"

begin
  ActiveRecord::Base.connection.execute(SQL)
rescue StandardError => e
  logger.error "Error message: #{e.message}\n#{e.backtrace}"
  puts 'Error occurred, more info in log/remove_orphan_validator_histories.log'
end
