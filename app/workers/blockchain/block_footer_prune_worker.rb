# frozen_string_literal: true

module Blockchain
  class BlockFooterPruneWorker
    include Sidekiq::Worker
    sidekiq_options retry: 0, dead: false, lock: :until_executed, queue: :blockchain

    def perform
      return if Rails.env.stage?

      Blockchain::BlockFooter::NETWORK_CLASSES.each_key do |network|
        Blockchain::BlockFooterPruneService.new(network: network).call
      end
    end
  end
end
