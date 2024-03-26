# frozen_string_literal: true

require 'test_helper'

class ValidatorSoftwareVersionTest < ActiveSupport::TestCase
  test '#running_latest_or_newer? returns true if validator is running an edge version' do
    v = ValidatorSoftwareVersion.new(number: '45.4.23')

    stub_current_major_minor_patch(v) do
      assert(v.running_latest_or_newer?)
    end
  end

  test '#running_latest_or_newer? returns true if validator is running the current version' do
    v = ValidatorSoftwareVersion.new(number: '1.5.8')
    stub_current_major_minor_patch(v) do
      assert(v.running_latest_or_newer?)
    end
  end

  test '#running_latest_or_newer? returns false if validator is behind the current major version' do
    v = ValidatorSoftwareVersion.new(number: '0.8.1')
    stub_current_major_minor_patch(v) do
      refute(v.running_latest_or_newer?)
    end
  end

  test '#running_latest_major_and_minor_or_newer? returns true if validator is running same minor version' do
    v = ValidatorSoftwareVersion.new(number: '1.5')
    stub_current_major_minor(v) do
      assert(v.running_latest_major_and_minor_or_newer?)
    end

    v = ValidatorSoftwareVersion.new(number: '1.5.0')
    stub_current_major_minor(v) do
      assert(v.running_latest_major_and_minor_or_newer?)
    end

    v = ValidatorSoftwareVersion.new(number: '1.5.1')
    stub_current_major_minor(v) do
      assert(v.running_latest_major_and_minor_or_newer?)
    end
  end

  test '#running_latest_major_and_minor_or_newer? returns false if validator is running an older minor version' do
    v = ValidatorSoftwareVersion.new(number: '1.4')
    stub_current_major_minor(v) do
      refute(v.running_latest_major_and_minor_or_newer?)
    end

    v = ValidatorSoftwareVersion.new(number: '1.4.9')
    stub_current_major_minor(v) do
      refute(v.running_latest_major_and_minor_or_newer?)
    end

    v = ValidatorSoftwareVersion.new(number: '1.4.0')
    stub_current_major_minor(v) do
      refute(v.running_latest_major_and_minor_or_newer?)
    end

    v = ValidatorSoftwareVersion.new(number: '0.4.0')
    stub_current_major_minor(v) do
      refute(v.running_latest_major_and_minor_or_newer?)
    end
  end

  test '::new accepts a second, optional `network` parameter' do
    ValidatorSoftwareVersion.new(number: '1.4.0', network: 'testnet')
  end

  test '::valid_software_version? returns false when a junk version is passed' do
    refute(ValidatorSoftwareVersion.valid_software_version?('unknown'))
    refute(ValidatorSoftwareVersion.valid_software_version?('null'))
    refute(ValidatorSoftwareVersion.valid_software_version?(false))

    assert(ValidatorSoftwareVersion.valid_software_version?('1.1'))
    assert(ValidatorSoftwareVersion.valid_software_version?('0.0.1'))
    assert(ValidatorSoftwareVersion.valid_software_version?('1.1.a'))
  end

  # these two methods ensure that our tests don't break when the actual cluster
  # version changes
  def stub_current_major_minor_patch(vsv)
    vsv.stub(:current_major_minor_patch, Gem::Version.new('1.5.8')) do
      yield
    end
  end

  def stub_current_major_minor(vsv)
    vsv.stub(:current_major_minor, Gem::Version.new('1.5')) do
      yield
    end
  end
end
