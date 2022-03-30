FactoryBot.define do
  factory :sol_price do
    currency { SolPrice.currency_usd }
    epoch_testnet { 2 }
    epoch_mainnet { 1 }
    
    trait :coin_gecko do 
      exchange { SolPrice.exchanges[:coin_gecko] }
      volume { 0.2059643190934253e10 }
      average_price { 0.1368354526288871e3 }
      datetime_from_exchange { DateTime.current - 1.day }
    end

    trait :ftx do 
      exchange { SolPrice.exchanges[:ftx] }
      open { 0.13617e3 }
      close { 0.13569e3 }
      high { 0.1408e3 }
      low { 0.1247425e3 }
      volume { 0.2059643190934253e10 }
      datetime_from_exchange { DateTime.current - 1.day }
    end
  end
end
