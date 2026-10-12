# frozen_string_literal: true

module Blockchain
  class AlpenglowPruneWorker
    include Sidekiq::Worker
    sidekiq_options retry: 0, dead: false, lock: :until_executed, queue: :blockchain

    def perform
      prune_footers unless Rails.env.stage?
      AlpenglowEpochRank.prune
    end

    private

    def prune_footers
      Blockchain::BlockFooter::NETWORK_CLASSES.each_key do |network|
        Blockchain::BlockFooterPruneService.new(network: network).call
      end
    end
  end
end
