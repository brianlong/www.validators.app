namespace :db do
  task generate_skipped_slot_percent_moving_averages: :environment do
    start_time = Time.now
    p start_time

    counter = 1

    # ValidatorBlockHistory.where("created_at > ?", 3.days.ago).order('id desc').find_each do |vbh|
    ValidatorBlockHistory.where("created_at > ?", 3.days.ago).order('id desc').each do |vbh|
      p vbh.id

      vbh.update_column(
        :skipped_slot_percent_moving_average,
        vbh.validator.validator_block_histories.last_24_hours.average(:skipped_slot_percent)
      )

      break if counter >= 100_000
      counter += 1
    end

    end_time = Time.now
    p end_time

    p end_time - start_time
  end
end
