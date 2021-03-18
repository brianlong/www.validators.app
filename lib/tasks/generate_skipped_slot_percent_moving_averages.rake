namespace :db do

  # TODO refactor to account for refactors to #previous_24_hours method
  task generate_vbh_skipped_slot_percent_moving_averages: :environment do
    start_time = Time.now
    p start_time

    counter = 1

    ValidatorBlockHistory.where("created_at > ?", 1.days.ago).find_each(order: :desc) do |vbh|
      p vbh.id

      vbh.update_column(
        :skipped_slot_percent_moving_average,
        vbh.validator.validator_block_histories.previous_24_hours.average(:skipped_slot_percent)
      )

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
