# frozen_string_literal: true

require "csv"

columns = %w[user_id amount signature response_time transaction_type network commitment_level success application reported_at slot_sent slot_landed]
file = "#{Rails.root}/tmp/ping_thing.csv"

CSV.open(file, "w") do |csv|
  csv << columns

  total = PingThing.count
  PingThing.all.find_each.with_index do |pt, index|
    print "\r#{index + 1} / #{total}"
    csv << columns.map { |col| pt.send(col) }
  end

  total = PingThing.count
  PingThingArchive.all.find_each.with_index do |pta, index|
    print "\r#{index + 1} / #{total}"
    csv << columns.map { |col| pta.send(col) }
  end
end
