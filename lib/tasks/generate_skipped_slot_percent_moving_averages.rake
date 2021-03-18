namespace :db do
  task generate_vbh_skipped_slot_percent_moving_averages: :environment do
    ValidatorBlockHistory.where("created_at > ?", 7.hours.ago).find_each(order: :desc) do |vbh|
      vbh.send(:set_skipped_slot_percent_moving_average)
    end
  end

  task generate_vbhs_skipped_slot_percent_moving_averages: :environment do
    ValidatorBlockHistoryStat.find_each(order: :desc) do |vbhs|
      vbhs.send(:set_skipped_slot_percent_moving_average)
    end
  end
end
