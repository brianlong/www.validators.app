# frozen_string_literal: true

module Blockchain
  class LeaderSchedule
    RETRY_INTERVAL = 60 # seconds
    CACHED_EPOCHS = 3

    def initialize(rpc_urls:, epoch_schedule:)
      @rpc = Blockchain::JsonRpcRequest.new(rpc_urls)
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
      leaders = @rpc.call("getLeaderSchedule", [@epoch_schedule.first_slot_in_epoch(epoch)])
      return nil if leaders.blank?

      leaders.each_with_object(Array.new(leaders.values.sum(&:size))) do |(identity, indexes), schedule|
        indexes.each { |index| schedule[index] = identity }
      end
    end
  end
end
