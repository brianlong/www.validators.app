require 'test_helper'

class KeybaseLogicTest < ActiveSupport::TestCase
  include KeybaseLogic

  test "get existing url" do
    VCR.use_cassette('keybase_logic/get_existing_url', record: :new_episodes) do
      keybase_id = "brianlong"
      test_avatar_url = "https://s3.amazonaws.com/keybase_processed_uploads/3af995d21a8fe4cec4d6e83104f87205_360_360.jpg"
      avatar_url = get_validator_avatar(keybase_id)
      assert_equal test_avatar_url, avatar_url
    end # VCR
  end

  test "get nonexistent url leaves empty avatar_url column" do
    VCR.use_cassette('keybase_logic/get_nonexistent_url', record: :new_episodes) do
      keybase_id = "brianlongbrianlong"
      avatar_url = get_validator_avatar(keybase_id)
      assert_nil avatar_url
    end # VCR
  end
end
