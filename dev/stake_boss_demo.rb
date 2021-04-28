# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)
require 'stake_boss_logic'

include StakeBossLogic

payload = {
  config_urls: ['https://testnet.solana.com'],
  network: 'testnet',
  stake_address: 'D5RjnPHuJuJC14ZeX5k3g8S9qJ8UanMvNxv3hEpp3zmC',
  split_n_ways: 2
}

p = Pipeline.new(200, payload)
            .then(&guard_stake_account)
            .then(&guard_duplicate_records)
            .then(&set_max_n_split)
            .then(&register_first_stake_account)
            .then(&split_primary_account)

puts "CODE: #{p[:code]}"
puts "MESSAGE: #{p[:message]}"
puts "ERROR: #{p[:errors].inspect}"
puts ''
puts 'stake account: '
puts p.payload[:stake_boss_stake_account].inspect
puts 'validators: '
puts p.payload[:validators].inspect
puts 'split n max: '
puts p.payload[:split_n_max]
