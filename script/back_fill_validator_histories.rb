# frozen_string_literal: true

# RAILS_ENV=production bundle exec ruby script/back_fill_validator_histories.rb

require_relative '../config/environment'

ValidatorHistory.where(["root_distance is null and created_at >= '2021-07-25'"]).find_each do |vh|
  max_root_height = ValidatorHistory.highest_root_block_for(
                                       vh.network,
                                       vh.batch_uuid
                                     ).to_i
  max_vote_height = ValidatorHistory.highest_last_vote_for(
                                       vh.network,
                                       vh.batch_uuid
                                     ).to_i
  vh.update(
    max_root_height: max_root_height,
    max_vote_height: max_vote_height,
    root_distance: max_root_height - vh.root_block.to_i,
    vote_distance: max_vote_height - vh.last_vote.to_i
  )
  # Go slow since this is just a 1-time backfill
  sleep(1)
end

# # TODO Reduce this down to a single DB query. N+1 is bad.
# @root_blocks = @val_histories.map do |vh|
#   ValidatorHistory.highest_root_block_for(params[:network], vh.batch_uuid) - vh.root_block
# end
#
# # TODO Reduce this down to a single DB query. N+1 is bad.
# @vote_blocks = @val_histories.map do |vh|
#   ValidatorHistory.highest_last_vote_for(params[:network], vh.batch_uuid) - vh.last_vote
# end
