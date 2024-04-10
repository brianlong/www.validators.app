# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)

require "csv"

columns = %w[user_id amount signature response_time transaction_type network commitment_level success application reported_at slot_sent slot_landed]
file_recent = "#{Rails.root}/tmp/ping_thing_recent.csv"
file_archive_root = "#{Rails.root}/tmp/ping_thing_archive"

puts "generating ping_thing_recent.csv"
CSV.open(file_recent, "w") do |csv|
  csv << columns

  total = PingThing.count
  PingThing.all.find_each.with_index do |pt, index|
    print "\r#{index + 1} / #{total}"
    csv << columns.map { |col| pt.send(col) }
  end
end
puts "done"

total_batches = PingThingArchive.count / 500_000

puts "generating ping_thing_archive_*.csv (total batches: #{total_batches})"
PingThingArchive.find_in_batches(batch_size: 500_000).with_index do |pta_batch, batch_index|
  file_archive = "#{file_archive_root}_#{batch_index}.csv"
  print "\r#{batch_index + 1} / #{total}"

  CSV.open(file_archive, "w") do |csv|
    csv << columns
    pta_batch.each do |pta|
      csv << columns.map { |col| pta.send(col) }
    end
  end
end
