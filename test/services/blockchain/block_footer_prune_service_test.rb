# frozen_string_literal: true

require "test_helper"

module Blockchain
  class BlockFooterPruneServiceTest < ActiveSupport::TestCase
    def footer(model, slot, created_at:, processed: true)
      model.create!(slot_number: slot, epoch: 1, processed: processed, created_at: created_at, updated_at: created_at)
    end

    test "#call deletes processed footers older than retention" do
      footer(Blockchain::AlpenglowCommunityBlockFooter, 1, created_at: 8.days.ago)
      footer(Blockchain::AlpenglowCommunityBlockFooter, 2, created_at: 8.days.ago, processed: false)
      footer(Blockchain::AlpenglowCommunityBlockFooter, 3, created_at: 6.days.ago)

      deleted = Blockchain::BlockFooterPruneService.new(network: "alpenglow-community").call

      assert_equal 1, deleted
      assert_equal [2, 3], Blockchain::AlpenglowCommunityBlockFooter.order(:slot_number).pluck(:slot_number)
    end

    test "#call deletes footers in batches" do
      5.times { |i| footer(Blockchain::TestnetBlockFooter, i, created_at: 10.days.ago) }

      stub_const(Blockchain::BlockFooterPruneService, :BATCH_SIZE, 2) do
        assert_equal 5, Blockchain::BlockFooterPruneService.new(network: "testnet").call
      end
      assert_equal 0, Blockchain::TestnetBlockFooter.count
    end

    test "worker prunes all footer networks and skips stage" do
      footer(Blockchain::AlpenglowCommunityBlockFooter, 1, created_at: 8.days.ago)
      footer(Blockchain::TestnetBlockFooter, 1, created_at: 8.days.ago)

      Rails.env.stub(:stage?, true) { Blockchain::BlockFooterPruneWorker.new.perform }
      assert_equal 1, Blockchain::AlpenglowCommunityBlockFooter.count

      Blockchain::BlockFooterPruneWorker.new.perform
      assert_equal 0, Blockchain::AlpenglowCommunityBlockFooter.count
      assert_equal 0, Blockchain::TestnetBlockFooter.count
    end

    def stub_const(klass, name, value)
      original = klass.const_get(name)
      klass.send(:remove_const, name)
      klass.const_set(name, value)
      yield
    ensure
      klass.send(:remove_const, name)
      klass.const_set(name, original)
    end
  end
end
