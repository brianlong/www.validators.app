# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)
include CollectorLogic

# Run `rails db:seed` first!
user = User.first
raise 'User not found' if user.nil?

client_ping_times = [
  {
    'user_id' => 1, 'network' => 'testnet', 'from_account' => 'ABCD',
    'from_ip' => '123.123.123.123', 'to_account' => 'EFGH',
    'to_ip' => '255.255.255.255', 'min_ms' => 0.881, 'avg_ms' => 1.238,
    'max_ms' => 2.428, 'mdev' => 0.597
  },
  {
    'user_id' => 1, 'network' => 'testnet', 'from_account' => 'ABCD',
    'from_ip' => '123.123.123.123', 'to_account' => 'IJKL',
    'to_ip' => '10.10.10.10', 'min_ms' => 1.881, 'avg_ms' => 2.238,
    'max_ms' => 3.428, 'mdev' => 1.597
  }
]

puts client_ping_times.to_json

collector = Collector.create(
  user_id: user.id,
  payload_type: 'ping_times',
  payload_version: 1,
  payload: client_ping_times.to_json
)

payload = { collector_id: collector.id }
result = Pipeline.new(200, payload)
                 .then(&collect_ping_times)

puts result.inspect
