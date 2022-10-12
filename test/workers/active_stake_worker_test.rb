require 'test_helper'
require 'sidekiq/testing'

class ActiveStakeWorkerTest < ActiveSupport::TestCase

  test 'worker should be performed as expected' do
    network = "mainnet"
    batch = create(:batch, :mainnet)
    batch_uuid = batch.uuid

    create(:validator_history, batch_uuid: batch_uuid, network: network)

    Sidekiq::Testing.inline! do
      ActiveStakeWorker.perform_async(network: network, batch_uuid: batch_uuid)

      cluster_stat = ClusterStat.where(network: network).last

      assert_equal network, cluster_stat.network
      assert_equal 100, cluster_stat.total_active_stake
    end
  end
end
