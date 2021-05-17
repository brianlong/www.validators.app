# frozen_string_literal: true

require 'test_helper'

# Valid regular account: testarBnsk6ZVZWthoBAmbn5wyA35Nc2Dr7QWWV9TRv
# Valid stake account:   BbeCzMU39ceqSgQoNs9c1j2zes7kNcygew8MEjEBvzuY
# Invalid stake account: BbeCzMU39ceqSgQoNs9c1j2zes7kNcygew8MEjEBvzuZ

class StakeBossLogicTest < ActiveSupport::TestCase
  include StakeBossLogic
  include ApplicationHelper

  def setup
    # Create our initial payload with the input values
    @initial_payload = {
      config_urls: ['https://testnet.solana.com'],
      network: 'testnet',
      stake_account: 'BbeCzMU39ceqSgQoNs9c1j2zes7kNcygew8MEjEBvzuY'
    }
  end

  def create_validators
    # create some validators that should not be delegated by StakeBoss
    @noname1 = Validator.create(
      network: 'testnet',
      account: 'A5oH9BPo6PRnEHmLnhtyN2YXELnbTotEUDB8axHVBcY4',
      name: 'noname'
    )
    @noname1.vote_accounts.create(
      # network: 'testnet',
      account: 'A5oH9BPo6PRnEHmLnhtyN2YXELnbTotEUDB8axHVBcY4'
    )
    create(
      :validator_score_v1,
      validator_id: @noname1.id,
      delinquent: true,
      data_center_key: '3265-NL-Bergschenhoek'
    ).update_column(:total_score, 10)

    @noname2 = Validator.create(
      network: 'testnet',
      account: 'Aom2EwxRjtcCZBDwqvaZiEZDPgmw4AsPQGVrsLa2srCg',
      name: 'noname'
    )
    @noname2.vote_accounts.create(
      # network: 'testnet',
      account: 'Aom2EwxRjtcCZBDwqvaZiEZDPgmw4AsPQGVrsLa2srCg'
    )
    create(
      :validator_score_v1,
      validator_id: @noname2.id,
      stake_concentration_score: -2,
      data_center_key: '3265-NL-Bergschenhoek'
    ).update_column(:total_score, 10)

    @noname3 = Validator.create(
      network: 'testnet',
      account: 'AxPP3kYU5RC1fsvaPRoaJCHsqGaxYJmV7vervCzVgn83',
      name: 'noname'
    )
    @noname3.vote_accounts.create(
      # network: 'testnet',
      account: 'AxPP3kYU5RC1fsvaPRoaJCHsqGaxYJmV7vervCzVgn83'
    )
    create(
      :validator_score_v1,
      validator_id: @noname3.id,
      data_center_key: '24940-DE-Nuremburg'
    ).update_column(:total_score, 10)

    # Marco Broeken
    @marco = Validator.create(
      network: 'testnet',
      account: '8SQEcP4FaYQySktNQeyxF3w8pvArx3oMEh7fPrzkN9pu',
      name: 'Stakeconomy.com'
    )
    @marco.vote_accounts.create(
      # network: 'testnet',
      account: '2HUKQz7W2nXZSwrdX5RkfS2rLU4j1QZLjdGCHcoUKFh3'
    )
    create(
      :validator_score_v1,
      validator_id: @marco.id,
      delinquent: false,
      stake_concentration_score: 0,
      data_center_concentration_score: 0,
      data_center_key: '3265-NL-Bergschenhoek'
    ).update_column(:total_score, 10)

    # Martin Smith
    @martin = Validator.create(
      network: 'testnet',
      account: '4XWxphAh1Ji9p3dYMNRNtW3sbmr5Z1cvsGyJXJx5Jvfy',
      name: 'Smith'
    )
    @martin.vote_accounts.create(
      # network: 'testnet',
      account: '38QX3p44u4rrdAYvTh2Piq7LvfVps9mcLV9nnmUmK28x'
    )
    create(
      :validator_score_v1,
      validator_id: @martin.id,
      delinquent: false,
      stake_concentration_score: 0,
      data_center_concentration_score: 0,
      data_center_key: '199610-RU-Moscow'
    ).update_column(:total_score, 9)
  end

  # Show that the input guards are working
  test 'guard_input \
        when the input is empty \
        returns Blank Address error and code 500' do
    # Blank input
    p = Pipeline.new(200, @initial_payload.merge(stake_address: nil))
                .then(&guard_input)
    assert_equal 500, p.code
    assert_equal StakeBossLogic::InvalidStakeAccount, p.errors.class
    assert_equal 'Invalid Stake Account: Blank Address', p.errors.message
  end

  test 'guard_input \
        when theres a javascript tag \
        returns javascript is not allowed error and code 500' do
    # javascript
    account = '"><script src=https://certus.xss.ht></script>'
    p = Pipeline.new(200, @initial_payload.merge(stake_address: account))
                .then(&guard_input)

    assert_equal 500,
                 p.code
    assert_equal StakeBossLogic::InvalidStakeAccount,
                 p.errors.class
    assert_equal 'Invalid Stake Account: Hi Leo, javascript is not allowed!',
                 p.errors.message
  end

  test 'guard_input \
        when theres wrong number of chars \
        returns wrong size error and code 500' do
    # Blank input
    p = Pipeline.new(200, @initial_payload.merge(stake_address: 'test'))
                .then(&guard_input)

    assert_equal 500,
                 p.code
    assert_equal StakeBossLogic::InvalidStakeAccount,
                 p.errors.class
    assert_equal 'Invalid Stake Account: Address is wrong size',
                 p.errors.message
  end

  test 'guard_stake_account \
        when account is not a stake account \
        returns not a Stake Account error and code 500' do
    address = 'FLC9P4DgGjQD53X1zsx1hA9HJhzjErzYeJk24Xdfpogx'
    json_data = \
      File.read("#{Rails.root}/test/stubs/solana_stake_account_#{address}.json")

    SolanaCliService.stub(
      :request,
      {
        cli_response: json_data, 
        cli_error: "Error: RPC request error: FLC9P4DgGjQD53X1zsx1hA9HJhzjErzYeJk24Xdfpogx is not a stake account\n"
      },
      [address, TESTNET_CLUSTER_URLS],
      true
    ) do
      p = Pipeline.new(200, @initial_payload.merge(stake_address: address))
                  .then(&guard_input)
                  .then(&guard_stake_account)
      assert_equal 500,
                 p.code
      assert_equal StakeBossLogic::InvalidStakeAccount,
                 p.errors.class
      assert_equal 'Invalid Stake Account: This is not a Stake Account',
                 p.errors.message
    end
  end


  test 'guard_input \
        when there are whitespaces in input \
        returns whitespaces error and code 500' do
    p = Pipeline.new(200, @initial_payload.merge(stake_address: 'te st'))
                .then(&guard_input)

    assert_equal 500,
                 p.code
    assert_equal StakeBossLogic::InvalidStakeAccount,
                 p.errors.class
    assert_equal 'Invalid Stake Account: whitespaces not allowed',
                 p.errors.message
  end

  test 'guard_input \
        when there are forbidden chars \
        returns illegal characters error and code 500' do
    illegal_chars = %w[+ - _ & | ' "]
    illegal_chars.each do |chr|
      account = SecureRandom.hex(16) + chr
      p = Pipeline.new(200, @initial_payload.merge(stake_address: account))
                  .then(&guard_input)
      assert_equal 500,
                   p.code
      assert_equal StakeBossLogic::InvalidStakeAccount,
                   p.errors.class
      assert_equal 'Invalid Stake Account: Address contains illegal characters',
                   p.errors.message
    end
  end

  test 'guard_stake_account \
        when stake account is invalid \
        returns Not a valid Stake Account error and code 500' do
    address = 'BbeCzMU39ceqSgQoNs9c1j2zes7kNcygew8MEjEBvzuZ'
    json_data = \
      File.read("#{Rails.root}/test/stubs/solana_stake_account_#{address}.json")

    SolanaCliService.stub(
      :request,
      json_data,
      [address, TESTNET_CLUSTER_URLS]
    ) do
      p = Pipeline.new(200, @initial_payload.merge(stake_address: address))
                  .then(&guard_input)
                  .then(&guard_stake_account)
      assert_equal 500,
                   p.code
      assert_equal StakeBossLogic::InvalidStakeAccount,
                   p.errors.class
      assert_equal 'Invalid Stake Account: Not a valid Stake Account',
                   p.errors.message
    end
  end

  test 'guard_stake_account \
        when stake boss does not have the stake authority \
        returns Stake Boss needs Stake Authority error and code 500' do
    address = '2tgq1PZGanqgmmLcs3PDx8tpr7ny1hFxaZc2LP867JuSa'
    json_data = \
      File.read("#{Rails.root}/test/stubs/solana_stake_account_#{address}.json")

    SolanaCliService.stub(
      :request,
      {cli_response: json_data, cli_error: nil},
      [address, TESTNET_CLUSTER_URLS]
    ) do
      p = Pipeline.new(200, @initial_payload.merge(stake_address: address))
                  .then(&guard_input)
                  .then(&guard_stake_account)
      assert_equal 500,
                   p.code
      assert_equal StakeBossLogic::InvalidStakeAccount,
                   p.errors.class
      assert_equal 'Invalid Stake Account: Stake Boss needs Stake Authority',
                   p.errors.message
    end
  end

  test 'guard_stake_account \
        when account is inactive \
        returns inactive error and code 500' do
    address = '2TqbsD5tW1bNRCZpRSDq7CejLVJwMNwuouvPaMdSdrk2'
    json_data = \
      File.read("#{Rails.root}/test/stubs/solana_stake_account_#{address}.json")

    SolanaCliService.stub(
      :request,
      {cli_response: json_data, cli_error: nil},
      [address, TESTNET_CLUSTER_URLS]
    ) do
      p = Pipeline.new(200, @initial_payload.merge(stake_address: address))
                  .then(&guard_input)
                  .then(&guard_stake_account)
      assert_equal 500,
                   p.code
      assert_equal StakeBossLogic::InvalidStakeAccount,
                   p.errors.class
      assert_equal 'Invalid Stake Account: Stake Account is inactive',
                   p.errors.message
    end
  end

  test 'guard_stake_account \
        with correct solana_stake_account \
        returns code 200 and valid solana stake account' do
    address = 'BbeCzMU39ceqSgQoNs9c1j2zes7kNcygew8MEjEBvzuY'
    json_data = \
      File.read("#{Rails.root}/test/stubs/solana_stake_account_#{address}.json")

    SolanaCliService.stub(
      :request,
      {cli_response: json_data, cli_error: nil},
      [address, TESTNET_CLUSTER_URLS]
    ) do
      p = Pipeline.new(200, @initial_payload.merge(stake_address: address))
                  .then(&guard_input)
                  .then(&guard_stake_account)

      assert_equal 200,
                   p.code
      assert       p.payload[:solana_stake_account].valid?
      assert       p.payload[:solana_stake_account].active?
      assert_equal 'BossttsdneANBePn2mJhooAewt3fo4aLg7enmpgMvdoH',
                   p.payload[:solana_stake_account].stake_authority
    end
  end

  test 'guard_duplicate_records \
        when the address is already in db \
        returns Duplicate Record error and code 500' do
    StakeBoss::StakeAccount.create!(
      network: 'testnet',
      address: 'BbeCzMU39ceqSgQoNs9c1j2zes7kNcygew8MEjEBvzuY'
    )

    address = 'BbeCzMU39ceqSgQoNs9c1j2zes7kNcygew8MEjEBvzuY'
    json_data = \
      File.read("#{Rails.root}/test/stubs/solana_stake_account_#{address}.json")

    SolanaCliService.stub(
      :request,
      json_data,
      [address, TESTNET_CLUSTER_URLS]
    ) do
      p = Pipeline.new(200, @initial_payload.merge(stake_address: address))
                  .then(&guard_duplicate_records)

      assert_equal 500, p.code
      assert_equal 'Invalid Stake Account: Duplicate Record', p.errors.message
    end
  end

  test 'split_n_ways \
        with correct input \
        returns code 200 and correct values' do
    address = 'BbeCzMU39ceqSgQoNs9c1j2zes7kNcygew8MEjEBvzuY'
    json_data = \
      File.read("#{Rails.root}/test/stubs/solana_stake_account_#{address}.json")

    SolanaCliService.stub(
      :request,
      {cli_response: json_data, cli_error: nil},
      [address, TESTNET_CLUSTER_URLS]
    ) do
      p = Pipeline.new(200, @initial_payload.merge(stake_address: address))
                  .then(&guard_input)
                  .then(&guard_stake_account)
                  .then(&guard_duplicate_records)
                  .then(&set_max_n_split)

      assert_equal 200,
                   p.code
      assert_equal 199.99771712,
                   lamports_to_sol(
                     p.payload[:solana_stake_account].delegated_stake
                   )
      assert_equal 2,
                   p.payload[:split_n_ways]
      assert_equal 32,
                   p.payload[:split_n_max]
    end
  end

  test 'select_validators \
        with correct input \
        returns code 200 and correct validators' do
    create_validators
    address = 'BbeCzMU39ceqSgQoNs9c1j2zes7kNcygew8MEjEBvzuY'
    json_data = \
      File.read("#{Rails.root}/test/stubs/solana_stake_account_#{address}.json")

    SolanaCliService.stub(
      :request,
      {cli_response: json_data, cli_error: nil},
      [address, TESTNET_CLUSTER_URLS]
    ) do
      p = Pipeline.new(200, @initial_payload.merge(stake_address: address))
                  .then(&guard_input)
                  .then(&guard_stake_account)
                  .then(&guard_duplicate_records)
                  .then(&set_max_n_split)
                  .then(&select_validators)
      assert_equal 200,
                   p.code
      assert_equal 199.99771712,
                   lamports_to_sol(
                     p.payload[:solana_stake_account].delegated_stake
                   )
      assert_equal 2,
                   p.payload[:split_n_ways]
      assert_equal 32,
                   p.payload[:split_n_max]
      assert_equal 1,
                   p.payload[:validators].count
      assert_equal '2HUKQz7W2nXZSwrdX5RkfS2rLU4j1QZLjdGCHcoUKFh3',
                   p.payload[:validators][0]
    end
  end

  test 'register_first_stake_account \
        with correct input
        returns 200 and correct stake account' do
    create_validators

    address = 'BbeCzMU39ceqSgQoNs9c1j2zes7kNcygew8MEjEBvzuY'
    json_data = \
      File.read("#{Rails.root}/test/stubs/solana_stake_account_#{address}.json")

    SolanaCliService.stub(
      :request,
      {cli_response: json_data, cli_error: nil},
      [address, TESTNET_CLUSTER_URLS]
    ) do
      assert_difference 'StakeBoss::StakeAccount.count' do
        p = Pipeline.new(200, @initial_payload.merge(stake_address: address))
                    .then(&guard_input)
                    .then(&guard_stake_account)
                    .then(&guard_duplicate_records)
                    .then(&set_max_n_split)
                    .then(&select_validators)
                    .then(&register_first_stake_account)

        assert_equal 200,
                     p.code
        assert_equal address,
                     p.payload[:stake_boss_stake_account].address
      end
    end
  end

  test 'split_primary_account \
        when primary_account is false \
        returns error not a primary account and code 500' do
    address = 'BbeCzMU39ceqSgQoNs9c1j2zes7kNcygew8MEjEBvzuY'
    json_data = \
      File.read("#{Rails.root}/test/stubs/solana_stake_account_#{address}.json")

    SolanaCliService.stub(
      :request,
      {cli_response: json_data, cli_error: nil},
      [address, TESTNET_CLUSTER_URLS]
    ) do
      p = Pipeline.new(200, @initial_payload.merge(stake_address: address))
                  .then(&guard_stake_account)
                  .then(&set_max_n_split)
                  .then(&register_first_stake_account)
      p.payload[:stake_boss_stake_account].update_column(:primary_account, false)
      p = p.then(&split_primary_account)

      assert_equal 500, p.code
      assert_equal InvalidStakeAccount, p.errors.class
      assert_equal 'Invalid Stake Account: Not the primary_account', p.errors.message
    end
  end

  test 'find_address_by_seed \
        with the correct input \
        returns correct address' do
    address = 'BbeCzMU39ceqSgQoNs9c1j2zes7kNcygew8MEjEBvzuY'

    SolanaCliService.stub(
      :request,
      {cli_response: 'BbeCzMU39ceqSgQoNs9c1j2zes7kNcygew8MEjEBvzuX', cli_error: nil},
      [address, TESTNET_CLUSTER_URLS]
    ) do
      addr = find_address_by_seed(
        seed: 1,
        urls: TESTNET_CLUSTER_URLS
      )

      assert_equal 'BbeCzMU39ceqSgQoNs9c1j2zes7kNcygew8MEjEBvzuX', addr
    end
  end

  test 'create_split_account \
        when the account to split is valid \
        returns valid attributes' do
    batch = Batch.create

    sbsa = StakeBoss::StakeAccount.create(
      address: 'BbeCzMU39ceqSgQoNs9c1j2zes7kNcygew8MEjEBvzuY',
      network: 'testnet',
      batch_uuid: batch.uuid,
      account_balance: 100
    )

    acc = create_split_account(
      network: 'testnet',
      batch: batch.uuid,
      split_account: sbsa,
      urls: TESTNET_CLUSTER_URLS
    )

    assert_equal sbsa.batch_uuid, acc.batch_uuid
    assert_equal false, acc.primary_account
  end

  test 'account_from_cli \
        with the correct input \
        returns valid account and no error' do
    address = 'BbeCzMU39ceqSgQoNs9c1j2zes7kNcygew8MEjEBvzuY'
    json_data = \
      File.read("#{Rails.root}/test/stubs/solana_stake_account_#{address}.json")

    SolanaCliService.stub(
      :request,
      {cli_response: json_data, cli_error: nil},
      [address, TESTNET_CLUSTER_URLS]
    ) do
      acc = account_from_cli(
        address: 'BbeCzMU39ceqSgQoNs9c1j2zes7kNcygew8MEjEBvzuY',
        urls: TESTNET_CLUSTER_URLS
      )

      assert_equal 'BbeCzMU39ceqSgQoNs9c1j2zes7kNcygew8MEjEBvzuY', acc.address
      assert_nil acc.cli_error
    end
  end

  test 'split_primary_account \
        when account has already been splitted \
        returns error already split and code 500' do
    address = 'BbeCzMU39ceqSgQoNs9c1j2zes7kNcygew8MEjEBvzuY'
    json_data = \
      File.read("#{Rails.root}/test/stubs/solana_stake_account_#{address}.json")

    SolanaCliService.stub(
      :request,
      {cli_response: json_data, cli_error: nil},
      [address, TESTNET_CLUSTER_URLS]
    ) do
      p = Pipeline.new(200, @initial_payload.merge(stake_address: address))
                  .then(&guard_stake_account)
                  .then(&set_max_n_split)
                  .then(&register_first_stake_account)
      p.payload[:stake_boss_stake_account]
       .update_column(:split_on, DateTime.now - 10.minutes)
      p = p.then(&split_primary_account)

      assert_equal 500, p.code
      assert_equal InvalidStakeAccount, p.errors.class
      assert_equal 'Invalid Stake Account: Already split', p.errors.message
    end
  end

  test 'split_primary_account 
        with valid input
        returns code 200 and minor accounts' do
    address = 'BbeCzMU39ceqSgQoNs9c1j2zes7kNcygew8MEjEBvzuY'
    p = Pipeline.new(200, @initial_payload.merge(stake_address: address))
    SolanaCliService.stub(
      :request,
      split_primary_account_stub(address: address),
      [address, TESTNET_CLUSTER_URLS]
    ) do
      p = p.then(&guard_stake_account)
           .then(&set_max_n_split)
           .then(&register_first_stake_account)
    end

    address = 'BbeCzMU39ceqSgQoNs9c1j2zes7kNcygew8MEjEBvzuX'

    SolanaCliService.stub(
      :request,
      split_primary_account_stub(address: address),
      [address, TESTNET_CLUSTER_URLS]
    ) do
      p = p.then(&split_primary_account)
    end

    assert_equal 1, p.payload[:minor_accounts].count
    assert_equal 200, p.code
  end

  def split_primary_account_stub(address:)
    proc do |arg|
      cli_req_name = arg[:cli_method].split(' ')[0]

      case cli_req_name
      when 'stake-account'
        json_data = \
          File.read("#{Rails.root}/test/stubs/solana_stake_account_#{address}.json")

        {cli_response: json_data, cli_error: nil}
      when 'split-stake'
        json_data = \
          File.read("#{Rails.root}/test/stubs/solana_stake_account_#{address}.json")

        { cli_response: json_data, cli_error: nil }
      when 'create-address-with-seed'
        {
          cli_response: 'BbeCzMU39ceqSgQoNs9c1j2zes7kNcygew8MEjEBvzuX', 
          cli_error: nil
        }
      when 'delegate-stake'
        {
          cli_response: '2NbhvTovBt4dki811xvDJJadG7rJCGeAqv9P2zA98GoP97icwGT5fcV5sJ3y35VsYLAjiyW7jmAyyYMSQsCTXNJ4',
         cli_error: nil
        }
      end
    end
  end
end
