# frozen_string_literal: true

require "test_helper"

class ArchivableTest < ActiveSupport::TestCase
  setup do
    10.times do |t|
      create(:stake_account_history, network: "testnet", created_at: t.days.ago)
    end
  end

  test "#archive_class returns the correct class" do
    assert_equal StakeAccountHistoryArchive, StakeAccountHistory.archive_class
  end

  test "#archive_due_to archives the correct records and destroys originals" do
    StakeAccountHistory.archive_due_to(date_to: 2.days.ago, network: "testnet", destroy_after_archive: true)

    assert_equal 8, StakeAccountHistoryArchive.where(network: "testnet").count
    assert_equal 2, StakeAccountHistory.where(network: "testnet").count
  end

  test "#archive_due_to does not destroy originals by default" do
    StakeAccountHistory.archive_due_to(date_to: 4.days.ago, network: "testnet")

    assert_equal 6, StakeAccountHistoryArchive.where(network: "testnet").count
    assert_equal 10, StakeAccountHistory.where(network: "testnet").count
  end

  test "archive_batch archives the correct records and destroys originals" do
    StakeAccountHistory.archive_batch(StakeAccountHistory.where(network: "testnet").to_a, archive: true, destroy_after_archive: true)

    assert_equal 10, StakeAccountHistoryArchive.where(network: "testnet").count
    assert_equal 0, StakeAccountHistory.where(network: "testnet").count
  end

  test "#archive_batch does not destroy originals by default" do
    StakeAccountHistory.archive_batch(StakeAccountHistory.where(network: "testnet").to_a, archive: true)

    assert_equal 10, StakeAccountHistoryArchive.where(network: "testnet").count
    assert_equal 10, StakeAccountHistory.where(network: "testnet").count
  end

  test "#archive_batch does not archive when archive is false, but can delete files" do
    StakeAccountHistory.archive_batch(StakeAccountHistory.where(network: "testnet").to_a, archive: false, destroy_after_archive: true)

    assert_equal 0, StakeAccountHistoryArchive.where(network: "testnet").count
    assert_equal 0, StakeAccountHistory.where(network: "testnet").count
  end
end
