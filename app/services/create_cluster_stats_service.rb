class CreateClusterStatsService
  def initialize(network: , batch_uuid: )
    @network = network
    @batch_uuid = batch_uuid
  end

  def call
    batch_uuid = p.payload[:batch_uuid]
    validator_history_stats = Stats::ValidatorHistory.new(@network, @batch_uuid)
    total_active_stake = validator_history_stats.total_active_stake

    ClusterStat.create(network: @network, total_active_stake: total_active_stake)
  end
end