# frozen_string_literal: true

# rails runner script/one_time_scripts/clean_invalid_skipped_votes.rb NETWORK

@network ||= ARGV[0] || "testnet"

raise "invalid network - #{@network}" unless NETWORKS.include? @network

invalid_percent = ->(val) { val.present? && val.to_f.abs > 1 }

vah_count = 0
VoteAccountHistory.where(network: @network)
                  .where("ABS(skipped_vote_percent_moving_average) > 1")
                  .in_batches(of: 5_000) do |relation|
  vah_count += relation.update_all(skipped_vote_percent_moving_average: nil)
end
puts "vote_account_histories cleaned: #{vah_count}"

batch_count = Batch.where(network: @network)
                   .where("ABS(best_skipped_vote) > 1 OR ABS(skipped_vote_all_median) > 100")
                   .update_all(best_skipped_vote: nil, skipped_vote_all_median: nil)
puts "batches cleaned: #{batch_count}"

score_count = 0
ValidatorScoreV1.where(network: @network).find_each do |score|
  skipped_vote_history = score.skipped_vote_history.to_a
  moving_average_history = score.skipped_vote_percent_moving_average_history.to_a

  next unless skipped_vote_history.any?(&invalid_percent) || moving_average_history.any?(&invalid_percent)

  score.update_columns(
    skipped_vote_history: skipped_vote_history.map { |val| invalid_percent.call(val) ? nil : val },
    skipped_vote_percent_moving_average_history: moving_average_history.map { |val| invalid_percent.call(val) ? nil : val }
  )
  score_count += 1
end
puts "validator_score_v1s cleaned: #{score_count}"
