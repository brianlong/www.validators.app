require 'test_helper'

class ValidatorUpdateAvatarUrlTest < ActiveSupport::TestCase

  test "validators with correct urls" do
    validators(:staking_fund, :medusa, :hashquark)
    urls = Validator.all.pluck(:avatar_url)
    VCR.use_cassette('validators_update_avatar_url/validators_with_correct_urls', record: :new_episodes) do
      load(Rails.root.join('script', 'validators_update_avatar_url.rb') )
      urls_after_script = Validator.all.pluck(:avatar_url)
      assert_equal urls, urls_after_script
    end
  end

  test "validators with broken urls" do
    broken_url = 'https://keybase.io/images/no-photo/placeholder-avatar-180-x-181@2x.png'
    Validator.all.each{ |v| v.update(avatar_url: broken_url) }
    VCR.use_cassette('validators_update_avatar_url/validators_with_broken_urls', record: :new_episodes) do
      assert_changes 'Validator.find(2).avatar_url == broken_url' do
        load(Rails.root.join('script', 'validators_update_avatar_url.rb') )
      end
    end
  end

  test "validators with default urls" do
    default_url = 'https://keybase.io/images/no-photo/placeholder-avatar-180-x-180@2x.png'
    Validator.all.each{ |v| v.update(avatar_url: default_url) }
    VCR.use_cassette('validators_update_avatar_url/validators_with_default_urls', record: :new_episodes) do
      assert_changes 'Validator.find(2).avatar_url == default_url' do
        load(Rails.root.join('script', 'validators_update_avatar_url.rb') )
      end
    end
  end
end