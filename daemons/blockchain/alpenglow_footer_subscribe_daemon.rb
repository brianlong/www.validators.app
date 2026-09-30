# frozen_string_literal: true

require_relative "../../config/environment"

SLEEP_TIME = 1 # second
FLUSH_SIZE = 100
FLUSH_INTERVAL = 20 # seconds
NETWORK = "alpenglow-community"

rpc_url = Rails.application.credentials.solana[:alpenglow_community_urls][0]
rpc_uri = URI(rpc_url)

def flush_footers(footers, epoch_schedule, leader_schedule)
  return if footers.empty?

  saved = Blockchain::AlpenglowFooterSaveService.new(
    network: NETWORK,
    footers: footers,
    epoch_schedule: epoch_schedule,
    leader_schedule: leader_schedule
  ).call
  puts "#{Time.current} saved #{saved} footers up to slot #{footers.last[:slot]}"
rescue => e
  puts "Failed to save #{footers.size} footers: #{e.message}"
  Appsignal.send_error(e)
ensure
  footers.clear
end

loop do
  footers = []
  epoch_schedule = nil
  leader_schedule = nil

  begin
    epoch_schedule = Blockchain::EpochSchedule.new(
      SolanaRpcClient.new(cluster: rpc_url).client.get_epoch_schedule.result
    )
    leader_schedule = Blockchain::LeaderSchedule.new(rpc_url: rpc_url, epoch_schedule: epoch_schedule)
    flushed_at = Time.current

    Blockchain::AlpenglowFooterSubscribeService.new(
      network: NETWORK,
      grpc_url: "#{rpc_uri.host}:#{rpc_uri.port}",
      token: rpc_uri.path.delete("/")
    ).call do |footer|
      footers << footer
      next unless footers.size >= FLUSH_SIZE || Time.current - flushed_at >= FLUSH_INTERVAL

      flush_footers(footers, epoch_schedule, leader_schedule)
      flushed_at = Time.current
    end
  rescue => e
    puts e
    puts e.backtrace

    sleep(SLEEP_TIME)
    next
  ensure
    flush_footers(footers, epoch_schedule, leader_schedule) if leader_schedule
  end
end
