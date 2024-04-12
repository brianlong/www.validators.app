# frozen_string_literal: true

require File.expand_path('../../config/environment', __dir__)

DELAY = 30.minutes

NETWORKS.each do |network|
  Blockchain::Slot.where(network: network, status: "request_error")
                  .where("created_at < ?", DELAY.ago)
                  .each do |slot|
    Blockchain::GetBlockWorker.set(queue: "blockchain").perform_async({"network" => network, "slot_number" => slot.slot_number})
  end
end
