# frozen_string_literal: true

require "test_helper"

class UpdateImageFileServiceTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  include VcrHelper

  def setup
    @namespace = File.join("services", "update_image_file_service")
    @cassette = self.class.name.underscore
    @validator = create(:validator, account: "test_account", avatar_url: "https://s3.amazonaws.com/keybase_processed_uploads/3af995d21a8fe4cec4d6e83104f87205_360_360.jpg")
    @service = UpdateImageFileService.new(@validator, :avatar)
    @tmp_file_path = Rails.root.join("tmp", "#{@validator.avatar_tmp_file_name}.jpeg")
    @avatar_file_path = Rails.root.join("tmp", "#{@validator.avatar_file_name}.png")
  end

  def teardown
    File.delete(@tmp_file_path) if File.exist?(@tmp_file_path)
    File.delete(@avatar_file_path) if File.exist?(@avatar_file_path)
    @validator.avatar.purge
  end

  test "call attaches new avatar if hash changes" do
    vcr_cassette(@namespace, @cassette) do
      assert_changes -> { @validator.reload.avatar.attached? }, from: false, to: true do
        @service.call
      end
    end
  end

  test "call does not attach avatar if hash is the same" do
    vcr_cassette(@namespace, @cassette) do
      @service.call
      @validator.reload
      assert @validator.avatar.attached?
      assert_no_difference -> { @validator.avatar.blob_id } do
        @service.call
        @validator.reload
      end
    end
  end

  test "call does nothing if avatar_url is blank" do
    @validator.update(avatar_url: nil)
    assert_no_difference -> { @validator.avatar.attached? ? 1 : 0 } do
      @service.call
    end
  end
end
