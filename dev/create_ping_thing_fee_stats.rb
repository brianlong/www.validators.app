%w[eu gb ua].each do |region|
  [0, 19 , 39, 59, 79, 99].each do |fee|
    24.times do |i|
      PingThingFeeStat.create(
        average_time: rand(100..5000),
        median_slot_latency: 0.0,
        median_time: rand(100..5000),
        min_slot_latency: 0.0,
        min_time: rand(100..5000),
        network: 'mainnet',
        p90_slot_latency: 0.0,
        p90_time: rand(100..5000),
        pinger_region: region,
        priority_fee_micro_lamports_average: rand(100..5000),
        priority_fee_percentile: fee,
        created_at: Time.zone.now - i.hours
      )
    end
  end
end