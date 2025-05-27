# frozen_string_literal: true

require 'test_helper'

class ValidatorUpdateAvatarUrlTest < ActiveSupport::TestCase
  include VcrHelper

  def setup
    @namespace = "validators_update_avatar_url"
  end

  test "validators with correct keybase urls remain unchanged" do
    url = "https://s3.amazonaws.com/keybase_processed_uploads/d56ce0bdda17f73d4aa895d1626e2505_360_360.jpg"
    validator = create(:validator, keybase_id: "polkachu", network: "testnet", avatar_url: url)
    vcr_cassette(@namespace, "validators_with_correct_keybase_urls") do
      load(Rails.root.join("script", "validators_update_keybase_avatar_url.rb") )
      assert_equal url, validator.reload.avatar_url
    end
  end

  test "validators with broken or old keybase urls get their avatars updated" do
    url = "https://s3.amazonaws.com/keybase_processed_uploads/a1413845d3aa5e3fec212768c3a87c05_360_360.jpg"
    validator = create(:validator, keybase_id: "coinbasecloud", network: "mainnet", avatar_url: url)
    vcr_cassette(@namespace, "validators_with_broken_or_old_keybase_ulrs") do
      load(Rails.root.join("script", "validators_update_keybase_avatar_url.rb") )
      refute_equal url, validator.reload.avatar_url
      assert_equal "https://s3.amazonaws.com/keybase_processed_uploads/68d8ed237f31e993a8eac1bca7512a05_360_360.jpg", validator.reload.avatar_url
    end
  end

  test "validators with non-keybase avatars remain unchanged" do
    url = "https://validator.b-cdn.net/validator-assets/img/logo/validator-logo-grad-bg.png"
    validator = create(:validator, keybase_id: "validatorcom", network: "mainnet", avatar_url: url)
    vcr_cassette(@namespace, "validators_with_non_keybase_avatars") do
      load(Rails.root.join("script", "validators_update_keybase_avatar_url.rb") )
      assert_equal url, validator.reload.avatar_url
    end
  end
end
