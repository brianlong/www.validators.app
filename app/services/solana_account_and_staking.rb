class SolanaAccountAndStaking
  # frozen_string_literal: true
  #
  # Can be removed after having ruby wrapper
  #
  # Initialize service
  # s = SolanaAccountAndStaking.new
  #
  # To create wallet:
  # s.create_wallet
  # s.add_correct_chmod
  # s.airdrop_sols(times: 10)
  #
  # To create stake_account:
  # Run above commands plus:
  # s.create_keypair_for_stake_account
  # s.create_stake_account
  #
  # You can split your account:
  #
  #

  def initialize(
    dir_path: Rails.root.join('tmp'),
    keypair_file: 'stake_boss_testnet_keypair_file.json', # 'my-keypair.json'
    url: 'https://api.testnet.solana.com',
    amount: 1,
    stake_account_file: 'stake-account.json'
  )
    @amount = amount
    @dir_path = dir_path
    @url = url

    @keypair_file = keypair_file
    @stake_account_file = stake_account_file

    @keypair_file_path = File.join(dir_path, @keypair_file)
    @stake_file_path = File.join(dir_path, @stake_account_file)

    @validators = nil
    @first_vote_account_pubkey = nil
  end

  def create_wallet
    command = "solana-keygen new --outfile #{@keypair_file_path}"
    `#{command}`
  end

  def add_correct_chmod
    `chmod 775 #{@keypair_file_path}`
  end

  def verify_wallet
    command = "solana-keygen verify #{wallet_pubkey} #{@keypair_file_path}"
    `#{command}`
  end

  def wallet_pubkey
    @wallet_pubkey ||= `solana-keygen pubkey #{@keypair_file_path}`.strip
  end

  def airdrop_sols(amount: 1)
    amount.times do
      airdrop_command = "airdrop 1 #{wallet_pubkey}"
      SolanaCliService.request(cli_method: airdrop_command, rpc_url: @url)
      sleep 1
    end

    current_balance = check_balance[:cli_response].scan(/\d+/).first

    puts "#{amount} SOL tokens added. Current balance: #{current_balance}"
  end

  def transfer_sols(recipient: 'BossttsdneANBePn2mJhooAewt3fo4aLg7enmpgMvdoH', amount: 1)
    transfer_command = "transfer --from #{@keypair_file_path} #{recipient} #{amount} --allow-unfunded-recipient --fee-payer #{@keypair_file_path}"
    SolanaCliService.request(cli_method: transfer_command, rpc_url: @url)
  end

  def check_balance
    balance_command = "balance #{wallet_pubkey}"
    SolanaCliService.request(cli_method: balance_command, rpc_url: @url)
  end

  def remove_wallet
    `rm #{@keypair_file_path}`
  end

  #
  # staking
  #
  def create_keypair_for_stake_account
    if File.exist?(@stake_file_path)
      puts 'file exists'
    else
      `solana-keygen new --no-passphrase -o #{@stake_file_path}`
    end
  end

  def create_stake_account(amount: @amount)
    stake_account_command = "create-stake-account --from #{@keypair_file_path} #{@stake_file_path} #{amount} \
      --stake-authority #{@keypair_file_path} --withdraw-authority #{@keypair_file_path} \
      --fee-payer #{@keypair_file_path}"

    SolanaCliService.request(cli_method: stake_account_command, rpc_url: @url)
  end

  def stake_account_pubkey
    @stake_account_pubkey ||= `solana-keygen pubkey #{@stake_file_path}`.strip
  end

  def view_stake_account(stake_account: @stake_file_path)
    command = "solana stake-account #{stake_account} --verbose"
    `#{command}`
  end

  def count_accounts
    count_accounts_command = "count #{wallet_pubkey}"
    SolanaCliService.request(
      cli_method: count_accounts_command,
      rpc_url: @url,
      tool: 'solana-stake-accounts',
      output: ''
    )
  end

  def stake_account_balances(number: 0)
    sa_balances_command = "balance #{wallet_pubkey} --num-accounts #{number}"
    SolanaCliService.request(
      cli_method: sa_balances_command,
      rpc_url: @url,
      tool: 'solana-stake-accounts',
      output: ''
    )
  end

  def stake_account_addresses(number: 0)
    account_addresses_command = "addresses #{wallet_pubkey} --num-accounts #{number}"
    SolanaCliService.request(
      cli_method: account_addresses_command,
      rpc_url: @url,
      tool: 'solana-stake-accounts',
      output: ''
    )
  end

  def delegate_stake(vote_account: first_vote_account_pubkey, stake_account_address: stake_account_pubkey)
    delegate_command = "delegate-stake --stake-authority #{@keypair_file_path} \
    #{stake_account_address} \
    #{vote_account} \
    --fee-payer #{@keypair_file_path}"

    SolanaCliService.request(cli_method: delegate_command, rpc_url: @url)
  end

  def split_stake(new_stake_account: stake_seed_string, amount: 1)
    split_command = ['split-stake']
    split_command.push "--stake-authority #{@keypair_file_path}"
    split_command.push "--fee-payer #{@keypair_file_path}"
    split_command.push '--commitment finalized'
    split_command.push "#{stake_account_pubkey}"
    split_command.push "#{@keypair_file_path}"
    split_command.push "--seed #{new_stake_account}"
    split_command.push amount.to_s
    split_command = split_command.join(' ')

    SolanaCliService.request(cli_method: split_command, rpc_url: @url)
  end

  def derive_stake_account(string: stake_seed_string, amount: 1)
    derive_command = "create-stake-account --from #{@keypair_file_path} #{@stake_file_path} --seed #{string} #{amount} \
    --stake-authority #{stake_account_pubkey} --withdraw-authority #{stake_account_pubkey} --fee-payer #{@keypair_file_path}"

    SolanaCliService.request(cli_method: derive_command, rpc_url: @url)
  end

  def derived_stake_account(seed_string: stake_seed_string)
    check_command = "create-address-with-seed --from #{stake_account_pubkey} #{seed_string} STAKE"
    cli_response = SolanaCliService.request(cli_method: check_command, rpc_url: @url)

    cli_response[:cli_response].strip
  end

  def withdraw_stake(amount: 1, stake_account: @stake_file_path)
    withdraw_command = "withdraw-stake --withdraw-authority #{@keypair_file_path} #{stake_account} #{wallet_pubkey} #{amount} \
    --fee-payer #{@keypair_file_path}"

    SolanaCliService.request(cli_method: withdraw_command, rpc_url: @url)
  end

  def merge_stake
    "solana merge-stake 9qA3V5vUN9wcLa6DS3PTst8YMD4FVwXR15vUW4wiyvTB 5gcBNPaeX6DwcYoAUSasYnpTMuMhyRtKETBXZsbyg2mx --fee-payer /home/rstolarski/Polcode/FMA/www.validators.app/tmp/stake_boss_testnet_keypair_file.json --keypair /home/rstolarski/Polcode/FMA/www.validators.app/tmp/stake_boss_testnet_keypair_file.json
    "
  end

  def check_balance_each_account(accounts: nil, number: 1)
    acc = accounts || get_accounts_pubkeys(number: number)
    acc.each do |account|
      res = view_stake_account(stake_account: account)
      puts account
      puts res
      puts "\n"

      sleep 3
    end
  end

  def get_accounts_pubkeys(number: 1)
    stake_account_addresses(number: number)[:cli_response].split("\n")
  end

  def remove_stake_account
    `rm #{@stake_file_path}`
  end

  #
  # Get validators
  #
  def validators
    validators_command = 'validators'
    cli_result = SolanaCliService.request(cli_method: validators_command, rpc_url: @url)
    json_result = JSON.parse(cli_result[:cli_response])
    @validators ||= json_result['validators']
  end

  def first_vote_account_pubkey
    @first_vote_account_pubkey ||= validators.first['voteAccountPubkey']
  end

  private
  def stake_seed_string
    '1'
  end
end
