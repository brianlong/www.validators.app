#frozen_string_literal: true

module PingThingsHelper
  def sort_stats_by_user(last_5_mins: {}, last_60_mins: {})
    data = {}
    (last_5_mins.keys + last_60_mins.keys).uniq.each do |username|
      data[username] = {
        last_5_mins: last_5_mins[username]&.first&.as_json || {},
        last_60_mins: last_60_mins[username]&.first&.as_json || {},
      }
    end

    data
  end
end
