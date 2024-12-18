class CollectorWorker
include Sidekiq::Worker
include CollectorLogic

  def perform(args)
    payload = { collector_id: args["collector_id"] }
    Pipeline.new(200, payload)
            .then(&ping_times_guard)
            .then(&ping_times_read)
            .then(&ping_times_calculate_stats)
            .then(&ping_times_save)
            .then(&log_errors)
  end
end
