# frozen_string_literal: true

require File.expand_path('../../config/environment', __dir__)

name = ARGV[0]
network = ARGV[1]

sp = StakePool.find_by!(name: name, network: network)

sp.stake_account_histories.delete_all
puts 'Stake account histories have been removed.'

sp.stake_accounts.delete_all
puts 'Stake Accounts have been removed.'

sp.delete
puts "Stake Pool #{name} has been removed."
