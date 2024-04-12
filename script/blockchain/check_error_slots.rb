# frozen_string_literal: true

require File.expand_path('../../config/environment', __dir__)

NETWORKS.each do |network|
  Blockchain::Slot.where(network: network, status: "response_error")
                  .where("created_at < ?", 30.minutes.ago)
                  .each do |slot|

    Blockchain::GetBlockService.new(network, slot.slot_number).call
  end
end
