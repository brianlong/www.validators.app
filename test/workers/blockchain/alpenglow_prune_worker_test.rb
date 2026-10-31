# frozen_string_literal: true

require "test_helper"

module Blockchain
  class AlpenglowPruneWorkerTest < ActiveSupport::TestCase
    def footer(model, created_at:)
      model.create!(slot_number: model.count + 1, epoch: 1, processed: true, created_at: created_at, updated_at: created_at)
    end

    def rank(created_at:)
      AlpenglowEpochRank.create!(
        network: "alpenglow-community", epoch: AlpenglowEpochRank.count + 1, rank: 0, vote_account: "Vote",
        validator_identity: "Identity", bls_pubkey: "bls", stake: 1, created_at: created_at
      )
    end

    test "#perform prunes footers of all networks and old ranks" do
      footer(Blockchain::AlpenglowCommunityBlockFooter, created_at: 8.days.ago)
      footer(Blockchain::TestnetBlockFooter, created_at: 8.days.ago)
      rank(created_at: 31.days.ago)
      recent_rank = rank(created_at: 29.days.ago)

      Blockchain::AlpenglowPruneWorker.new.perform

      assert_equal 0, Blockchain::AlpenglowCommunityBlockFooter.count
      assert_equal 0, Blockchain::TestnetBlockFooter.count
      assert_equal [recent_rank.id], AlpenglowEpochRank.pluck(:id)
    end

    test "#perform keeps shared footers on stage but prunes its own ranks" do
      footer(Blockchain::AlpenglowCommunityBlockFooter, created_at: 8.days.ago)
      rank(created_at: 31.days.ago)

      Rails.env.stub(:stage?, true) { Blockchain::AlpenglowPruneWorker.new.perform }

      assert_equal 1, Blockchain::AlpenglowCommunityBlockFooter.count
      assert_equal 0, AlpenglowEpochRank.count
    end
  end
end
