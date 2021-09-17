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

        Pipeline.new(200, p.payload)
      rescue StandardError => e
        Pipeline.new(500, p.payload, 'Error from log_info', e)
      end
    end

    def assign_epochs
      lambda do |p|
        p.payload[:prices_from_exchange].each do |price|
          epochs = find_epochs(price)

          price[:epoch_testnet] = epochs[:epoch_testnet]
          price[:epoch_mainnet] = epochs[:epoch_mainnet]
        end

        Pipeline.new(200, p.payload)
      rescue StandardError => e
        Pipeline.new(500, p.payload, 'Error from assign_epochs', e)
      end
    end

    def save_sol_prices
      lambda do |p|
        p.payload[:prices_from_exchange].each do |sol_price|
          datetime_from_exchange = sol_price[:datetime_from_exchange]

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

    # Helper methods
    def find_epochs(price)
      epochs = { epoch_testnet: nil, epoch_mainnet: nil }
      datetime = price[:datetime_from_exchange]
  
      before_condition = "network = ? AND created_at <= ?"
      after_condition = "network = ? AND created_at >= ?"
  
      epoch_testnet_before = EpochHistory.where(before_condition, 'testnet', datetime)
                                         .order("created_at DESC")
                                         .limit(1).take
      epoch_testnet_after = EpochHistory.where(after_condition, 'testnet', datetime)
                                        .order("created_at ASC")
                                        .limit(1).take
  
      epoch_mainnet_before = EpochHistory.where(before_condition, 'mainnet', datetime)
                                        .order("created_at DESC")
                                        .limit(1).take
      epoch_mainnet_after = EpochHistory.where(after_condition, 'mainnet', datetime)
                                        .order("created_at ASC")
                                        .limit(1).take
  
      epoch_testnet_dates = [epoch_testnet_before, epoch_testnet_after].compact
      epoch_mainnet_dates = [epoch_mainnet_before, epoch_mainnet_after].compact

      if epoch_testnet_dates.size == 2 && epoch_mainnet_dates.size == 2
        epoch_testnet = epoch_testnet_dates.sort_by do |date|
          (date.created_at - datetime.to_time).abs 
        end.first
        epoch_mainnet = epoch_mainnet_dates.sort_by  do |date| 
          (date.created_at - datetime.to_time).abs 
        end.first

        epochs[:epoch_testnet] = epoch_testnet.epoch
        epochs[:epoch_mainnet] = epoch_mainnet.epoch
      end

      epochs
    end
  end
end
