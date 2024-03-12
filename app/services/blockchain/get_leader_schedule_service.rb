#frozen_string_literal: true

module Blockchain
  class GetLeaderScheduleService
    include SolanaRequestsLogic

    def initialize(network, epoch, config_urls = nil)
      @network = network
      @epoch = epoch
      @config_urls = config_urls || Rails.application.credentials.solana["#{network}_urls".to_sym]
    end

    def call
      if !Blockchain::Slot.where(network: @network, epoch: @epoch).exists?
        response = cli_request("leader-schedule --epoch #{@epoch}", @config_urls)
        begin
          schedule = response["leaderScheduleEntries"]
          schedule.each do |entry|
            Blockchain::Slot.create(
              network: @network,
              epoch: @epoch,
              slot_number: entry["slot"],
              leader: entry["leader"],
              has_block: false
            )
          end
        rescue StandardError => e
          Appsignal.send_error(e)
          return
        end
      end
    end
  end
end
