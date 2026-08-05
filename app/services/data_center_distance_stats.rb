# frozen_string_literal: true

class DataCenterDistanceStats
  def initialize(network)
    @by_key = DataCenterStat.where(network: network)
                            .where.not(root_distance: nil)
                            .joins(:data_center)
                            .pluck("data_centers.data_center_key", :root_distance, :vote_distance, :active_validators_count)
                            .each_with_object({}) do |(key, root_distance, vote_distance, count), hash|
                              hash[key] = {
                                root_distance: root_distance,
                                vote_distance: vote_distance,
                                count: count.to_i
                              }
                            end
  end

  # dc_keys can be a single data_center_key or an array of them (for ASN groups
  # that span multiple data centers) - averages are weighted by validators count.
  def average_root_distance_for(dc_keys)
    weighted_average(dc_keys) { |entry| entry[:root_distance]&.dig("average") }
  end

  def average_vote_distance_for(dc_keys)
    weighted_average(dc_keys) { |entry| entry[:vote_distance]&.dig("average") }
  end

  private

  def weighted_average(dc_keys)
    entries = Array(dc_keys).filter_map { |key| @by_key[key] }
    total_count = entries.sum { |entry| entry[:count] }
    return nil if total_count.zero?

    weighted_sum = entries.sum { |entry| yield(entry).to_f * entry[:count] }
    weighted_sum / total_count.to_f
  end
end
