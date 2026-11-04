# frozen_string_literal: true

module Blockchain
  class EpochSchedule
    MINIMUM_SLOTS_PER_EPOCH = 32

    attr_reader :slots_per_epoch, :first_normal_epoch, :first_normal_slot

    def self.fetch(network)
      schedule = Blockchain::JsonRpcRequest.new(NETWORK_URLS[network]).call("getEpochSchedule")
      raise "Epoch schedule unavailable for #{network}" if schedule.nil?

      new(schedule)
    end

    def initialize(schedule)
      @slots_per_epoch = schedule.fetch("slotsPerEpoch")
      @first_normal_epoch = schedule.fetch("firstNormalEpoch")
      @first_normal_slot = schedule.fetch("firstNormalSlot")
    end

    def epoch_for(slot)
      if slot < first_normal_slot
        (slot + MINIMUM_SLOTS_PER_EPOCH).bit_length - MINIMUM_SLOTS_PER_EPOCH.bit_length
      else
        first_normal_epoch + (slot - first_normal_slot) / slots_per_epoch
      end
    end

    def first_slot_in_epoch(epoch)
      if epoch < first_normal_epoch
        (2**epoch - 1) * MINIMUM_SLOTS_PER_EPOCH
      else
        first_normal_slot + (epoch - first_normal_epoch) * slots_per_epoch
      end
    end
  end
end
