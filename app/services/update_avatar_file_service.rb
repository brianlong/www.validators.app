#frozen_string_literal: true

require "digest/md5"
require "open-uri"
require "image_processing/mini_magick"

STORAGE_PATH = Rails.root.join("storage", "validators", "avatars").to_s.freeze
IMAGE_SIZE_LIMIT = [320, 320].freeze
LOG_PATH = Rails.root.join("log", "update_avatar_file_service.log").to_s.freeze

class UpdateAvatarFileService
  def initialize(validator)
    @validator = validator
    logger = Logger.new(LOG_PATH)
    @tmp_file = nil
    @avatar_file = nil
  end

  def call(keep_tmp_files: false)
    if @validator.avatar_url.present?
      if @tmp_file = download_tmp_file
        if @validator.avatar_hash != tmp_file_md5
          if @avatar_file = process_and_save_avatar
            update_attached_avatar
            @validator.avatar_hash = tmp_file_md5
            @validator.save
          end
        end
        purge_files
      end
    end
  end

  def download_tmp_file
    download = URI.open(@validator.avatar_url)
    tmp_file_path = STORAGE_PATH + "/tmp/" + @validator.avatar_tmp_file_name
    if IO.copy_stream(download, @tmp_file).positive?
      logger.info("Downloaded file: " + tmp_file_path)
      tmp_file_path
    else
      logger.error("Error downloading file: " + tmp_file_path)
      nil
    end
  end

  def tmp_file_md5
    Digest::MD5.file(@tmp_file).hexdigest
  end

  def process_and_save_avatar
    destination = STORAGE_PATH + "/" + @validator.avatar_file_name
    ImageProcessing::MiniMagick
      .source(@tmp_file)
      .convert("png")
      .resize_to_limit(*IMAGE_SIZE_LIMIT)
      .call(destination: destination)

    destination
  end

  def update_attached_avatar
    @validator.avatar.purge
    @validator.avatar.attach(io: File.open(@avatar_file), filename: @validator.avatar_file_name)
  end

  def purge_files
    unless keep_tmp_files
      File.delete(@tmp_file) if File.exist?(@tmp_file)
      File.delete(@avatar_file) if File.exist?(@avatar_file)
    end
  end
end
