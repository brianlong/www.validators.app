namespace :db do
  task generate_vbh_skipped_slot_percent_moving_averages: :environment do
    start_time = Time.now
    p start_time

    ValidatorBlockHistory.where("created_at > ?", 1.days.ago).find_each(order: :desc) do |vbh|
      p vbh.id

      vbh.send(:set_skipped_slot_percent_moving_average)
    end

    end_time = Time.now
    p end_time

    p end_time - start_time
  end

  task generate_vbhs_skipped_slot_percent_moving_averages: :environment do
    ValidatorBlockHistoryStat.find_each(order: :desc) do |vbhs|
      vbhs.send(:set_skipped_slot_percent_moving_average)
    end
  end
end
