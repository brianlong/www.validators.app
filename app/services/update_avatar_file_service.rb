#frozen_string_literal: true

require "digest/md5"
require "open-uri"
require "image_processing/mini_magick"
#require 'rmagick'

STORAGE_PATH = Rails.root.join("tmp").to_s.freeze
IMAGE_SIZE_LIMIT = [320, 320].freeze
LOG_PATH = Rails.root.join("log", "update_avatar_file_service.log").to_s.freeze

class UpdateAvatarFileService
  def initialize(validator)
    @validator = validator
    @logger = Logger.new(LOG_PATH)
    @tmp_file = nil
    @avatar_file = nil
  end

  def call(keep_tmp_files: false)
    if @validator.avatar_url.present?

      # Download raw file from validator avatar_url
      if download_tmp_file
        if @validator.avatar_hash != tmp_file_md5
          @logger.info("Found new image for validator: " + @validator.account)
          if process_and_save_avatar
            update_attached_avatar
            @validator.avatar_hash = tmp_file_md5
            @validator.save
          end
        end
        purge_files(keep_tmp_files)
      end
    end
  end

  def download_tmp_file
    download = URI.open(@validator.avatar_url)
    @tmp_file = STORAGE_PATH + "/" + @validator.avatar_tmp_file_name
    if IO.copy_stream(download, @tmp_file).positive?
      @logger.info("Downloaded file: " + @tmp_file)
      @tmp_file
    else
      @logger.error("Error downloading file: " + @tmp_file)
      nil
    end
  end

  def tmp_file_md5
    Digest::MD5.file(@tmp_file).hexdigest
  end

  def process_and_save_avatar
    @avatar_file = STORAGE_PATH + "/" + @validator.avatar_file_name
    begin
      # frames_count = MiniMagick::Image.new(@tmp_file).pages.count
      # if frames_count > 1
      #   process_gif_file
      # else
      #   process_image_file
      # end
      process_image_file
    rescue => e
      Appsignal.send_error(e)
    end

    if File.exist?(@avatar_file)
      @logger.info("Prepared file to attach: " + @avatar_file)
      @avatar_file
    else
      @logger.error("Error preparing file to attach: " + @avatar_file)
      nil
    end
  end

  def process_gif_file
    original_gif = File.new(@tmp_file)
    frames = Magick::ImageList.new.from_blob original_gif.read
    frames = frames.coalesce.remap
    frames.each do |x|
      x.resize_to_fit!(*IMAGE_SIZE_LIMIT)
    end
    frames = frames.optimize_layers( Magick::OptimizeLayer )
    File.open(@avatar_file, "wb") { |f| f.write frames.to_blob }
  end

  def process_image_file
    ImageProcessing::MiniMagick.source(@tmp_file)
                               .convert("png")
                               .resize_to_limit(*IMAGE_SIZE_LIMIT)
                               .call(destination: @avatar_file)
  end

  def update_attached_avatar
    @validator.avatar.purge
    @logger.info("Purged old avatar for validator: " + @validator.account)
    @validator.avatar.attach(io: File.open(@avatar_file), filename: @validator.avatar_file_name)
    @logger.info("Attached new avatar for validator: " + @validator.account)
  end

  def purge_files(keep_tmp_files)
    unless keep_tmp_files
      File.delete(@tmp_file) if @tmp_file && File.exist?(@tmp_file)
      File.delete(@avatar_file) if @avatar_file && File.exist?(@avatar_file)
    end
  end
end