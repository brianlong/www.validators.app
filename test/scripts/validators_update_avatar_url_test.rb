require 'test_helper'

class ValidatorUpdateAvatarUrlTest < ActiveSupport::TestCase

  def setup
    Validator.create([{
      keybase_id: 'stakingfund',
      network: 'testnet',
      account: '2345',
      avatar_url: "https://s3.amazonaws.com/keybase_processed_uploads/d48739023a250815c4ac564c9870ec05_360_360.jpg"
    },{
      keybase_id: 'nikitainbar',
      network: 'testnet',
      account: '3456',
      avatar_url: "https://s3.amazonaws.com/keybase_processed_uploads/3efdd9c766508d123c15677e075e5d05_360_360.jpg"
    },{
      keybase_id: 'zhanglianghui',
      network: 'testnet',
      account: '4567',
      avatar_url: "https://s3.amazonaws.com/keybase_processed_uploads/5a7a92ba3326454e654e76eaeb9c3d05_360_360.jpg"
    }])
  end

  test "validators with correct urls" do
    urls = Validator.all.pluck(:avatar_url)
    VCR.use_cassette('validators_update_avatar_url/validators_with_correct_urls', record: :new_episodes) do
      load(Rails.root.join('script', 'validators_update_avatar_url.rb') )
      urls_after_script = Validator.all.pluck(:avatar_url)
      assert_equal urls, urls_after_script
    end
  end

  test "validators with broken urls" do
    broken_url = 'https://incorrect-url.png'
    Validator.all.each{ |v| v.update(avatar_url: broken_url) }
    VCR.use_cassette('validators_update_avatar_url/validators_with_broken_urls', record: :new_episodes) do
      assert_changes 'Validator.last.avatar_url == broken_url' do
        load(Rails.root.join('script', 'validators_update_avatar_url.rb') )
      end
    end
  end

  test "validators with default urls" do
    default_url = 'https://keybase.io/images/no-photo/placeholder-avatar-180-x-180@2x.png'
    Validator.all.each{ |v| v.update(avatar_url: default_url) }
    VCR.use_cassette('validators_update_avatar_url/validators_with_default_urls', record: :new_episodes) do
      assert_changes 'Validator.last.avatar_url == default_url' do
        load(Rails.root.join('script', 'validators_update_avatar_url.rb') )
      end
    end
  end
end
