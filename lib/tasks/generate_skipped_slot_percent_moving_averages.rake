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

  task generate_v1_score_skipped_slot_moving_average_history: :environment do
    ValidatorScoreV1.find_each(order: :desc) do |score|
      prev_24_hours = score.validator.validator_block_histories.last.previous_24_hours.pluck(:skipped_slot_percent)

      moving_average = array_average(prev_24_hours << skipped_slot_percent.to_f)

      score
    end
  end
end
