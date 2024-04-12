# frozen_string_literal: true

require "test_helper"

class UpdateAvatarFileServiceTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  include VcrHelper

  def setup
    @namespace = File.join("services", "update_avatar_file_service")
    @cassette = self.class.name.underscore
    @validator = create(
      :validator,
      account: "test_account",
      avatar_url: "https://s3.amazonaws.com/keybase_processed_uploads/3af995d21a8fe4cec4d6e83104f87205_360_360.jpg"
    )
    @service = UpdateAvatarFileService.new(@validator)
    @tmp_file_path = Rails.root.join("tmp", "#{@validator.avatar_tmp_file_name}.jpeg")
    @avatar_file_path = Rails.root.join("tmp", "#{@validator.avatar_file_name}.png")
  end

  def teardown
    File.delete(@tmp_file_path) if File.exist?(@tmp_file_path)
    @validator.avatar.purge
  end

  test "#download_tmp_file downloads original image" do
    vcr_cassette(@namespace, @cassette) do
      @service.download_tmp_file
      assert File.exist?(@tmp_file_path)
      File.delete(@tmp_file_path)
    end
  end

  test "#download_tmp_file doesnt download original file if type is different than image" do
    vcr_cassette(@namespace, @cassette + "-html") do
      @validator.update(avatar_url: "https://example.com")
      @service = UpdateAvatarFileService.new(@validator)
      refute @service.download_tmp_file
      refute File.exist?(Rails.root.join("tmp", "#{@validator.avatar_tmp_file_name}.html"))
    end
  end

  test "#set_tmp_file_path sets correct temporary file path" do
    path = Rails.root.join("tmp", @validator.avatar_tmp_file_name)
    assert_equal "#{path}.jpeg", @service.set_tmp_file_path("image/jpeg")
    assert_equal "#{path}.png", @service.set_tmp_file_path("image/png")
    assert_equal "#{path}.webp", @service.set_tmp_file_path("image/webp")
    assert_equal "#{path}.bmp", @service.set_tmp_file_path("image/bmp")
    assert_equal "#{path}.svg", @service.set_tmp_file_path("image/svg+xml")
  end

  test "#tmp_file_md5 matches correct image hash" do
    vcr_cassette(@namespace, @cassette) do
      @service.download_tmp_file

      assert_equal "354833ea399133ef004b6a4f40740ecd", @service.tmp_file_md5
    end
  end

  test "#process_and_save_avatar saves image ready to attach" do
    vcr_cassette(@namespace, @cassette) do
      @service.download_tmp_file
      @service.process_and_save_avatar

      assert File.exist?(@avatar_file_path)

      @service.purge_files(false)
    end
  end

  test "#update_attached_avatar attaches image to validator" do
    vcr_cassette(@namespace, @cassette) do
      @service.download_tmp_file
      @service.process_and_save_avatar
      @service.update_attached_avatar

      assert @validator.avatar.attached?

      @service.purge_files(false)
    end
  end

  test "#process_and_save_avatar skips processing animated gifs" do
    @validator.update(avatar_url: "https://upload.wikimedia.org/wikipedia/commons/c/c0/An_example_animation_made_with_Pivot.gif")
    @validator.reload

    vcr_cassette(@namespace, @cassette + "-gif") do
      @service.download_tmp_file
      @service.process_and_save_avatar

      refute @validator.avatar.attached?
      refute File.exist?(@avatar_file_path)
    end
  end

  test "#process_image_file does not raise any exception when processing animated gifs" do
    @validator.update(avatar_url: "https://upload.wikimedia.org/wikipedia/commons/c/c0/An_example_animation_made_with_Pivot.gif")
    @validator.reload

    vcr_cassette(@namespace, @cassette + "-gif") do
      assert_nothing_raised do
        @service.download_tmp_file
        @service.process_image_file
      end
    end
  end
end
