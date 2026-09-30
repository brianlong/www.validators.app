# frozen_string_literal: true

module Blockchain
  class LeaderSchedule
    RETRY_INTERVAL = 60 # seconds
    CACHED_EPOCHS = 3

    def initialize(rpc_url:, epoch_schedule:)
      @rpc_url = rpc_url
      @epoch_schedule = epoch_schedule
      @schedules = {}
      @failed_at = {}
    end

    def leader_for(slot)
      epoch = @epoch_schedule.epoch_for(slot)
      schedule_for(epoch)&.at(slot - @epoch_schedule.first_slot_in_epoch(epoch))
    end

    private

    def schedule_for(epoch)
      return @schedules[epoch] if @schedules.key?(epoch)
      return nil if @failed_at[epoch] && Time.current - @failed_at[epoch] < RETRY_INTERVAL

      schedule = fetch(epoch)
      if schedule
        @schedules[epoch] = schedule
        @schedules.delete(@schedules.keys.min) while @schedules.size > CACHED_EPOCHS
        @failed_at.delete(epoch)
      else
        @failed_at[epoch] = Time.current
      end
      schedule
    end

    def fetch(epoch)
      body = { jsonrpc: "2.0", id: 1, method: "getLeaderSchedule", params: [@epoch_schedule.first_slot_in_epoch(epoch)] }
      response = SolanaRpcRuby::ApiClient.new(@rpc_url).call_api(body: body.to_json, http_method: :post)
      leaders = JSON.parse(response.body)["result"]
      return nil if leaders.blank?

      leaders.each_with_object(Array.new(leaders.values.sum(&:size))) do |(identity, indexes), schedule|
        indexes.each { |index| schedule[index] = identity }
      end
    rescue SolanaRpcRuby::ApiError, JSON::ParserError => e
      Rails.logger.error("Failed to fetch leader schedule for epoch #{epoch}: #{e.message}")
      nil
    end
  end
end
