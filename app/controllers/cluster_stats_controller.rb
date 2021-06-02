# frozen_string_literal: true

# PublicController
class ClusterStats < ApplicationController
  def index
    batch = Batch.last_scored('mainnet')
    mainnet_vah_query = VoteAccountHistoryQuery.new('mainnet', batch.uuid)
    mainnet_vbh_query = ValidatorBlockHistoryQuery.new('mainnet', batch.uuid)

    @mainnet = {
      skipped_votes_percent:
        mainnet_vah_query.skipped_votes_stats,
      skipped_votes_percent_moving_average:
        mainnet_vah_query.skipped_vote_moving_average_stats,
      root_distance: {},
      vote_distance: {},
      skipped_slots: {},
      software_version: {}
    }

    @testnet = {
      skipped_votes_percent: {},
      root_distance: {},
      vote_distance: {},
      skipped_slots: {},
      software_version: {}
    }
  end
end
