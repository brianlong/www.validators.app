module SolPrices
  module SharedLogic
    def log_info
      lambda do |p|
        log_dir_path = File.join(Rails.root, 'log', 'sol_prices')
        log_name = "#{DateTime.current}_sol_prices.log"
        log_path = File.join(log_dir_path, log_name)
        
        FileUtils.mkdir_p(log_dir_path)

        logger = Logger.new(log_path)
        logger.debug(p.payload)
      end
    end

    def find_epoch
      lambda do |p|
        # We will run this pipeline just after the midnight 
        # so we can assume that last Epoch History will be correct.
        # 
        # We can later find the closest record to the date to be more specific.
        epoch_testnet = EpochHistory.where(network: 'testnet').last
        epoch_mainnet = EpochHistory.where(network: 'mainnet').last
  
        Pipeline.new(
          200, p.payload.merge(
            epoch_testnet: epoch_testnet&.epoch,
            epoch_mainnet: epoch_mainnet&.epoch
          )
        )
      rescue StandardError => e
        Pipeline.new(500, p.payload, 'Error from find_epoch', e)
      end
    end

    def save_sol_prices
      lambda do |p|
        p.payload[:prices_from_exchange].each do |sol_price|
          datetime_from_exchange = sol_price[:datetime_from_exchange]
          epoch_testnet = p.payload[:epoch_testnet] 
          epoch_mainnet = p.payload[:epoch_mainnet]
          
          sol_price.epoch_testnet = epoch_testnet if epoch_testnet
          sol_price.epoch_mainnet = epoch_mainnet if epoch_mainnet

          SolPrice.where(
            exchange: p.payload[:exchange],
            datetime_from_exchange: datetime_from_exchange
          ).first_or_create(sol_price)
        end
                
        Pipeline.new(200, p.payload)
      rescue StandardError => e
        Pipeline.new(500, p.payload, 'Error from save_sol_prices', e)
      end
    end
  end
end
