# frozen_string_literal: true

module BlockFooterDaemonHelper
  SLEEP_TIME = 1 # second
  FLUSH_SIZE = 100
  FLUSH_INTERVAL = 20 # seconds

  def run_block_footer_daemon(network)
    rpc_urls = NETWORK_URLS[network]
    rpc_uri = URI(rpc_urls.first)

    loop do
      footers = []
      epoch_schedule = nil
      leader_schedule = nil

      begin
        epoch_schedule = Blockchain::EpochSchedule.fetch(network)
        leader_schedule = Blockchain::LeaderSchedule.new(rpc_urls: rpc_urls, epoch_schedule: epoch_schedule)
        flushed_at = Time.current

        Blockchain::BlockFooterSubscribeService.new(
          network: network,
          grpc_url: "#{rpc_uri.host}:#{rpc_uri.port}",
          token: rpc_uri.path.delete("/")
        ).call do |footer|
          footers << footer
          next unless footers.size >= FLUSH_SIZE || Time.current - flushed_at >= FLUSH_INTERVAL

          flush_footers(network, footers, epoch_schedule, leader_schedule)
          flushed_at = Time.current
        end
      rescue => e
        puts e
        puts e.backtrace

        sleep(SLEEP_TIME)
        next
      ensure
        flush_footers(network, footers, epoch_schedule, leader_schedule) if leader_schedule
      end
    end
  end

  def flush_footers(network, footers, epoch_schedule, leader_schedule)
    return if footers.empty?

    saved = Blockchain::BlockFooterSaveService.new(
      network: network,
      footers: footers,
      epoch_schedule: epoch_schedule,
      leader_schedule: leader_schedule
    ).call
    puts "#{Time.current} saved #{saved} #{network} footers up to slot #{footers.last[:slot]}"
  rescue => e
    puts "Failed to save #{footers.size} #{network} footers: #{e.message}"
    Appsignal.send_error(e)
  ensure
    footers.clear
  end
end
