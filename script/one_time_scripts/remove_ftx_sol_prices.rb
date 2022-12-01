# frozen_string_literal: true

log_path = File.join(Rails.root, 'log', 'remove_ftx_sol_prices.log')
logger = Logger.new(log_path)

FTX_INDEX = SolPrice::EXCHANGES.index('ftx') || 1

begin
  SolPrice.where(exchange: 1).destroy_all
rescue StandardError => e
  logger.error "Error message: #{e.message}\n#{e.backtrace}"
  puts 'Error occurred, more info in log/remove_ftx_sol_prices.log'
end
