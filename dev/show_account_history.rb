# frozen_string_literal: true

# Accept an account or token address on the command line and show the history
#
# ruby dev/show_account_history.rb [ACCOUNT]
require File.expand_path('../config/environment', __dir__)

raise "Dev script can't be executed on production" if Rails.env.production?

require 'csv'

account = ARGV[0]
rpc_url = 'https://api.rpcpool.com'

include SolanaLogic

# A Quick module for thinking through a possible Transaction class
module AccountSupport
  include ApplicationHelper

  # Encapsulate a Transaction with some extra methods
  class ConfirmedTransaction
    attr_reader :result, :signatures, :account_keys, :pre_balances, :post_balances, :pre_token_balances, :post_token_balances, :slot

    def initialize(json)
      @result = json['result']
      @slot = json['result']['slot']
      @signatures = json['result']['transaction']['signatures']
      @account_keys = json['result']['transaction']['message']['accountKeys']
      @pre_balances = json['result']['meta']['preBalances']
      @post_balances = json['result']['meta']['postBalances']
      @pre_token_balances = json['result']['meta']['preTokenBalances']
      @post_token_balances = json['result']['meta']['postTokenBalances']
    end

    # Return an array of entries in debit, credit format
    # [account, debit, credit]
    def entries_regular
      i = 0
      result = []
      account_keys.each do |a|
        next if a.include?('1111111111111111111111111')

        if post_balances[i] > pre_balances[i]
          debit = post_balances[i] - pre_balances[i]
          credit = 0
        else
          debit = 0
          credit = pre_balances[i] - post_balances[i]
        end
        result << [
                    slot,
                    a,
                    lamports_to_sol(debit),
                    lamports_to_sol(credit),
                    lamports_to_sol(post_balances[i]),
                    signatures[0]]
        i += 1
      end
      result
    end
  end
end
include AccountSupport

begin
  raise "Account is missing" unless account

  # Get an array of transaction signatures ranked from newest to oldest
  signatures = SolanaCliService.request_with_params(
                 'transaction-history', rpc_url, account
               ).split("\n")
                .map{ |e| e if !e.include?('transaction') }
                .compact

  # puts signatures.inspect
  # puts ''

  # Loop through the signatures and fetch the related transactions
  transactions = {}
  signatures.each do |t|
    transactions[t] = rpc_request_with_params(
                       'getConfirmedTransaction',
                       [rpc_url],
                       [t]
                     )
  end

  # puts "HOME:     #{ENV['HOME']}"
  # puts "HOMEPATH: #{ENV['HOMEPATH']}"

  out_file = "#{ENV['HOME']}/solana_transactions_#{account}.csv"

  # puts transactions.inspect
  # puts ''
  CSV.open(out_file, 'w') do |csv|
    csv << ['slot', 'account', 'debit', 'credit', 'new balance', 'signature']
    transactions.each do |k, v|
      # puts k
      # puts "  #{v.inspect}"
      tr = ConfirmedTransaction.new(v)
      # byebug
      # puts "  #{tr.signatures}"
      # puts "  #{tr.account_keys}"
      # puts "  #{tr.pre_balances}"
      # puts "  #{tr.post_balances}"
      # puts "  #{tr.pre_token_balances}"
      # puts "  #{tr.post_token_balances}"
      tr.entries_regular.each do |er|
        csv << er
        # puts "    #{er}"
      end
      # puts ''
    end
  end

  puts ''
  puts "Results written to #{out_file}"
  puts ''
rescue StandardError => e
  puts "#{e.class}\n#{e.message}\n#{e.backtrace}"
end # begin


# Sample Output:
# "5WCHtxxSHRBm1tmYvFVEqQqAeEvazsoKfEtE7otcpcyLrReLPj3FqpfgH1XuARWTCgZaP1pvbcZD2UstkEVcvkhm" => {
#  "jsonrpc"=>"2.0",
#  "result"=>{
#    "blockTime"=>1618541006,
#    "meta"=>{
#      "err"=>nil,
#      "fee"=>5000,
#      "innerInstructions"=>[],
#      "logMessages"=>[
#         "Program 11111111111111111111111111111111 invoke [1]",
#         "Program 11111111111111111111111111111111 success"
#      ],
#      "postBalances"=>[45079760000, 354257213766, 1],
#      "postTokenBalances"=>[],
#      "preBalances"=>[345079765000, 54257213766, 1],
#      "preTokenBalances"=>[],
#      "status"=>{"Ok"=>nil}},
#      "slot"=>73873290,
#      "transaction"=>{
#        "message"=>{
#          "accountKeys"=>[
#            "7ts8ZvxP39NpkvGdSbHAQJQ9kPKDwvDGKJiWBqgrrM7e",
#            "GX2nQ97752wacL67Erj1zwQcwnfaegDsJL1vmCad9q9",
#            "11111111111111111111111111111111"
#          ],
#        "header"=>{
#        "numReadonlySignedAccounts"=>0,
#        "numReadonlyUnsignedAccounts"=>1,
#        "numRequiredSignatures"=>1},
#        "instructions"=>[
#          {
#            "accounts"=>[0, 1],
#            "data"=>"3Bxs3zyeY7SydUGF",
#            "programIdIndex"=>2
#          }
#        ],
#        "recentBlockhash"=>"EHZtD817mip4cKg6h2ebJkmTy4CYXniVRdes1MBpyZj"
#       },
#       "signatures"=>[
# "5WCHtxxSHRBm1tmYvFVEqQqAeEvazsoKfEtE7otcpcyLrReLPj3FqpfgH1XuARWTCgZaP1pvbcZD2UstkEVcvkhm"
#        ]
#      }
#     },
#   "id"=>1
# }
