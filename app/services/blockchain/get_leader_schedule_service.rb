# frozen_string_literal: true

module Blockchain
  class GetLeaderScheduleService
    include SolanaRequestsLogic

    LOG_PATH = Rails.root.join("log", "#{self.name.demodulize.underscore}.log")

    def initialize(network, epoch, config_urls = nil)
      @network = network
      @epoch = epoch
      @config_urls = config_urls || Rails.application.credentials.solana["#{network}_urls".to_sym]
      @logger ||= Logger.new(LOG_PATH)
    end

    def call
      puts Blockchain::Slot.network(@network)

      if Blockchain::Slot.network(@network).where(epoch: @epoch).exists?
        @logger.info("Leader schedule for epoch #{@epoch} on #{@network} already exists")
      else
        @logger.info("Fetching leader schedule for epoch #{@epoch} on #{@network}")
        response = cli_request("leader-schedule --epoch #{@epoch}", @config_urls)
        schedule = response["leaderScheduleEntries"]
        schedule.each do |entry|
          Blockchain::Slot.network(@network).create(
            epoch: @epoch,
            slot_number: entry["slot"],
            leader: entry["leader"]
          )
        end
        @logger.info("Leader schedule for epoch #{@epoch} on #{@network} saved")
      end
    rescue StandardError => e
      @logger.error("Error saving leader schedule for epoch #{@epoch} on #{@network}: #{e.message}")
      Appsignal.send_error(e)
      return
    end
  end
end
