# frozen_string_literal: true

# CollectorLogic
module CollectorLogic
  # collect_ping_times will read a Collector object with PingTimes and import
  # the data into the ping_times table.
  #
  # This method will be called from a Sidekiq worker.
  #
  # Expects to see p[:payload][:collector_id]
  def collect_ping_times
    lambda do |p|
      return p unless p[:code] == 200

      collector = Collector.find(p[:payload][:collector_id])

      # Guards
      if collector.nil?
        return Pipeline.new(404, p[:payload], 'Collector not found')
      end
      if collector.payload_type != 'ping_times'
        return Pipeline.new(400, p[:payload], 'Wrong payload_type')
      end
      if collector.payload_version != 1
        return Pipeline.new(400, p[:payload], 'Wrong payload_version')
      end

      # Import the records
      batch_id = SecureRandom.uuid
      ping_times = JSON.parse(collector.payload)
      # byebug

      ActiveRecord::Base.transaction do
        ping_times.each do |pt|
          # Create the ping_times record
          PingTime.create!(
            batch_id: batch_id,
            network: pt['network'],
            from_account: pt['from_account'],
            from_ip: pt['from_ip'],
            to_account: pt['to_account'],
            to_ip: pt['to_ip'],
            min_ms: pt['min_ms'],
            avg_ms: pt['avg_ms'],
            max_ms: pt['max_ms'],
            mdev: pt['mdev']
          )
        end
        # destroy the collector
        collector.destroy!
      end

      return Pipeline.new(200, p[:payload])
    rescue StandardError => e
      Pipeline.new(500, p[:payload], 'Error from collect_ping_times', e)
    end
  end
end
