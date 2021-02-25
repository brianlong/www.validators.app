require 'test_helper'

class ValidatorSoftwareVersionTest < ActiveSupport::TestCase
  test '#running_latest_or_edge? returns true if validator is running an edge version' do
    v = ValidatorSoftwareVersion.new(number: '45.4.23')
    assert(v.running_latest_or_edge?)
  end

  test '#running_latest_or_edge? returns true if validator is running the current version' do
    current_version = YAML.load(File.read('config/cluster.yml'))['software_patch_mainnet']
    v = ValidatorSoftwareVersion.new(number: current_version)
    assert(v.running_latest_or_edge?)
  end

  test '#running_latest_or_edge? returns false if validator is behind the current major version' do
    v = ValidatorSoftwareVersion.new(number: '0.8.1')
    refute(v.running_latest_or_edge?)
  end

  test '#running_latest_minor? returns true if validator is running same minor version' do
    v = ValidatorSoftwareVersion.new(number: '1.5')
    assert(v.running_latest_minor?)

    v = ValidatorSoftwareVersion.new(number: '1.5.0')
    assert(v.running_latest_minor?)

    v = ValidatorSoftwareVersion.new(number: '1.5.1')
    assert(v.running_latest_minor?)
  end

  test '#running_latest_minor? returns true if validator is running an older minor version' do
    v = ValidatorSoftwareVersion.new(number: '1.4')
    refute(v.running_latest_minor?)

    v = ValidatorSoftwareVersion.new(number: '1.4.9')
    refute(v.running_latest_minor?)

    v = ValidatorSoftwareVersion.new(number: '1.4.0')
    refute(v.running_latest_minor?)
  end

  test '#new accepts a second, optional `network` parameter' do
    ValidatorSoftwareVersion.new(number: '1.4.0', network: 'testnet')
  end
end
