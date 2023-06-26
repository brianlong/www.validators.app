# frozen_string_literal: true

require "test_helper"
require "sidekiq/testing"

# ReportLogicTest
class ReportLogicTest < ActiveSupport::TestCase
  include ReportLogic
  include SolanaLogic

  def setup
    @network = "mainnet"
    @batch = create(:batch, @network)
  end

  def generate_report
    payload = { network: @network, batch_uuid: @batch.uuid }
    Pipeline.new(200, payload).then(&report_software_versions)
  end

  test "report_software_versions creates correct report with software versions included" do
    software_versions = ["1.6.8", "1.7.1", "1.7.2"]
    software_versions.each do |sw|
      list = create_list(:validator, 5, network: @network)
      list.each do |validator|
        create(:validator_score_v1, validator: validator, software_version: sw)
      end
    end

    generate_report
    report = Report.find_by(name: "report_software_versions", batch_uuid: @batch.uuid)
    expected_result = { "count" => 5, "stake_percent" => 33.33 }

    assert_equal @network, report.network
    assert_equal @batch.uuid, report.batch_uuid
    assert_equal 3, report.payload.size # empty and unknown software_versions are ignored

    software_versions.each do |sw|
      assert_equal report.payload.find { |v| v[sw] }[sw], expected_result
    end
  end

  test "report_software_versions creates a report when active_stake sum is zero" do
    validator = create(:validator, network: @network)
    create(
      :validator_score_v1,
      software_version: "1.5.7",
      validator: validator,
      active_stake: 0
    )

    generate_report
    report = Report.find_by(name: "report_software_versions", batch_uuid: @batch.uuid)

    assert_equal 1, report.payload.size
    assert report.payload.first.keys, ["1.5.7"]
  end

  test "does not create a report if active_stake sum is nil" do
    validator = create(:validator, network: @network)
    create(:validator_score_v1,
      software_version: "1.5.7",
      validator: validator,
      active_stake: nil
    )

    generate_report
    report = Report.find_by(name: "report_software_versions", batch_uuid: @batch.uuid)

    assert_nil report
  end

  test "does not create a report if software version is malformed" do
    validator = create(:validator, network: @network)
    create(:validator_score_v1, validator: validator, software_version: "1.3.9 e45f1df5")

    generate_report
    report = Report.find_by(name: "report_software_versions", batch_uuid: @batch.uuid)

    assert_nil report
  end

  test "does not create a report if software version is unknown" do
    validator = create(:validator, network: @network)
    create(:validator_score_v1, validator: validator, software_version: "unknown")

    generate_report
    report = Report.find_by(name: "report_software_versions", batch_uuid: @batch.uuid)

    assert_nil report
  end

  test "does not create a report if software version is empty" do
    validator = create(:validator, network: @network)
    create(:validator_score_v1, validator: validator, software_version: "")

    generate_report
    report = Report.find_by(name: "report_software_versions", batch_uuid: @batch.uuid)

    assert_nil report
  end
end
