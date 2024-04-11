#frozen_string_literal: true

require "digest/md5"
require "open-uri"
require "image_processing/mini_magick"

STORAGE_PATH = Rails.root.join("tmp").to_s.freeze
IMAGE_SIZE_LIMIT = [320, 320].freeze
LOG_PATH = Rails.root.join("log", "update_avatar_file_service.log").to_s.freeze

IMAGE_TYPES = %w[image/png image/gif image/jpeg image/webp image/avif image/svg+xml image/bmp]

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
    file_type = download.meta["content-type"].to_s

    if file_type.in?(IMAGE_TYPES)
      @tmp_file = set_tmp_file_path(file_type)
    else
      @logger.error("Error downloading file for #{@validator.account}: incorrect file type #{file_type}")
      return false
    end

    if IO.copy_stream(download, @tmp_file).positive?
      @logger.info("Downloaded file: #{@tmp_file}")
      @tmp_file
    else
      @logger.error("Error downloading file for #{@validator.account}: #{@tmp_file}")
      nil
    end
  end

  def set_tmp_file_path(file_type)
    extension = file_type.split("/").last&.split("+")&.first
    STORAGE_PATH + "/" + @validator.avatar_tmp_file_name + "." + extension
  end

  def tmp_file_md5
    Digest::MD5.file(@tmp_file).hexdigest
  end

  def process_and_save_avatar
    @avatar_file_path = STORAGE_PATH + "/" + @validator.avatar_file_name
    begin
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

  def process_image_file
    if @tmp_file.end_with?(".svg")
      # Do not convert SVG files
      FileUtils.cp(@tmp_file, "#{@avatar_file_path}.svg")
      return @avatar_file = "#{@avatar_file_path}.svg"
    end

    @avatar_file = ImageProcessing::MiniMagick.source(@tmp_file)
                                              .convert("png")
                                              .resize_to_limit(*IMAGE_SIZE_LIMIT)
                                              .call(destination: "#{@avatar_file_path}.png")
    @avatar_file = "#{@avatar_file_path}.png"
  rescue ImageProcessing::Error => e
    # Skips animated gifs processing
    return if MiniMagick::Image.new(@tmp_file).pages.count > 1

    raise e
  end

  def update_attached_avatar
    @validator.avatar.purge
    @logger.info("Purged old avatar for validator: " + @validator.account)
    @validator.avatar.attach(io: File.open(@avatar_file), filename: @validator.avatar_file_name)
    @logger.info("Attached new avatar for validator: " + @validator.account)
  end

  def purge_files(keep_tmp_files)
    unless keep_tmp_files
      Dir[STORAGE_PATH + "/*_#{@validator.network}*"].entries.each do |file|
        File.delete(file)
        @logger.info("Deleted file: " + file)
      end
    end
  end
end
