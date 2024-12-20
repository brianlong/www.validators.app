# frozen_string_literal: true

# CollectorLogic
module CollectorLogic
  include PipelineLogic
  REQUIRED_PAYLOAD_FIELDS = %w[network avg_ms min_ms max_ms from_account to_account from_ip to_ip].freeze

  # guard_ping_times will check the collector payload type & version
  #
  # Expects to see p[:payload][:collector_id]
  def ping_times_guard
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

      REQUIRED_PAYLOAD_FIELDS.each do |field|
        return Pipeline.new(400, p[:payload], "No payload field: #{field}") unless collector.payload =~ /#{field}/
      end

      # Pass the collector object with the payload for subsquent steps
      return Pipeline.new(200, p[:payload].merge(collector: collector))
    rescue StandardError => e
      Pipeline.new(500, p[:payload], 'Error from guard_ping_times', e)
    end
  end

  # Read the ping_times from the collector object and set a batch_uuid
  #
  # Expects to see p[:payload][:collector]
  def ping_times_read
    lambda do |p|
      return p unless p[:code] == 200

      batch_uuid = SecureRandom.uuid
      ping_times = JSON.parse(p[:payload][:collector].payload)

      # Pass the batch_uuid & ping_times through for subsequent steps
      return Pipeline.new(
        200,
        p[:payload].merge(
          batch_uuid: batch_uuid,
          ping_times: ping_times
        )
      )
    rescue StandardError => e
      Pipeline.new(500, p[:payload], 'Error from ping_times_read', e)
    end
  end

  # Calculate stats from the batch of ping_times. Pass the results through in
  # p[:payload][:ping_time_stats]
  def ping_times_calculate_stats
    lambda do |p|
      return p unless p[:code] == 200

      # Calculate Average Ping Times
      average_times = p[:payload][:ping_times].map do |pt|
        pt['avg_ms'] unless pt['avg_ms'].nil?
      end
      average_times = average_times.reject { |a| a.to_s.empty? }
      overall_average_time = \
        average_times.inject { |sum, el| sum + el }.to_f / average_times.size

      min_times = p[:payload][:ping_times].map do |pt|
        pt['min_ms'] unless pt['min_ms'].nil?
      end
      min_times = min_times.reject { |a| a.to_s.empty? }
      overall_min_time = min_times.min

      max_times = p[:payload][:ping_times].map do |pt|
        pt['max_ms'] unless pt['max_ms'].nil?
      end
      max_times = max_times.reject { |a| a.to_s.empty? }
      overall_max_time = max_times.max

      return Pipeline.new(
        200,
        p[:payload].merge(
          ping_time_stats: {
            batch_uuid: p[:payload][:batch_uuid],
            overall_min_time: overall_min_time,
            overall_max_time: overall_max_time,
            overall_average_time: overall_average_time,
            observed_at: p[:payload][:ping_times].last['observed_at']
          }
        )
      )
    rescue StandardError => e
      Pipeline.new(500, p[:payload], 'Error from ping_times_calculate_stats', e)
    end
  end

  # collect_ping_times will read a Collector object with PingTimes and import
  # the data into the ping_times table.
  #
  # Expects to see p[:payload][:collector], p[:payload][:batch_uuid], &
  # p[:payload][:ping_times]
  def ping_times_save
    lambda do |p|
      return p unless p[:code] == 200

      # Import the records
      # batch_uuid = SecureRandom.uuid
      # ping_times = JSON.parse(p[:payload][:collector].payload)
      # byebug

      ActiveRecord::Base.transaction do
        p[:payload][:ping_times].each do |pt|
          # Create the ping_times record
          PingTime.create!(
            batch_uuid: p[:payload][:batch_uuid],
            network: pt['network'],
            from_account: pt['from_account'],
            from_ip: pt['from_ip'],
            to_account: pt['to_account'],
            to_ip: pt['to_ip'],
            min_ms: pt['min_ms'],
            avg_ms: pt['avg_ms'],
            max_ms: pt['max_ms'],
            mdev: pt['mdev'],
            observed_at: pt['observed_at']
          )
        end

        # Create the PingTimeStat record
        PingTimeStat.create(
          batch_uuid: p[:payload][:ping_time_stats][:batch_uuid],
          overall_min_time: p[:payload][:ping_time_stats][:overall_min_time],
          overall_max_time: p[:payload][:ping_time_stats][:overall_max_time],
          overall_average_time: \
            p[:payload][:ping_time_stats][:overall_average_time],
          observed_at: p[:payload][:ping_time_stats][:observed_at],
          network: p[:payload][:ping_times].last['network']
        )

        # destroy the collector
        p[:payload][:collector].destroy!
      end

      return Pipeline.new(200, p[:payload])
    rescue StandardError => e
      Pipeline.new(500, p[:payload], 'Error from collect_ping_times', e)
    end
  end
end
