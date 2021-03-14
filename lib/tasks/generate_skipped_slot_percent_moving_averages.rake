namespace :db do
  task generate_vbh_skipped_slot_percent_moving_averages: :environment do
    start_time = Time.now
    p start_time

    counter = 1

    ValidatorBlockHistory.where("created_at > ?", 2.days.ago).find_each(order: :desc) do |vbh|
      p vbh.id

      vbh.update_column(
        :skipped_slot_percent_moving_average,
        vbh.validator.validator_block_histories.last_24_hours.average(:skipped_slot_percent)
      )

    end

    end_time = Time.now
    p end_time

    p end_time - start_time
  end

  task generate_vbhs_skipped_slot_percent_moving_averages: :environment do
    ValidatorBlockHistoryStat.find_each(order: :desc) do |vbhs|
      records_in_range = ValidatorBlockHistoryStat.where(network: vbhs.network)
                                                        .where('created_at >= ?', vbhs.created_at - 24.hours)
                                                        .where('created_at < ?', vbhs.created_at)

      skipped_slot_ratios = records_in_range.map { |vbhs| vbhs.total_slots_skipped.to_f / vbhs.total_slots }

      running_avg = skipped_slot_ratios.sum(0.0) / skipped_slot_ratios.length

      unless running_avg.nan?
        vbhs.update_column(:skipped_slot_percent_moving_average, running_avg)
      end
    end
  end
end
