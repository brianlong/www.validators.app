# frozen_string_literal: true

module ImageProcessingHelper
  require "digest/md5"
  require "open-uri"
  require "image_processing/mini_magick"

  IMAGE_SIZE_LIMIT = [320, 320].freeze

  # Downloads a temporary file from the given URL attribute if it is a valid image type.
  def download_tmp_file(url_attr_name, obj_with_image, logger = Rails.logger)
    return unless obj_with_image.send(url_attr_name).present?

    download = URI.open(obj_with_image.send(url_attr_name))
    file_type = download.meta["content-type"].to_s

    if file_type.in?(obj_with_image.class::IMAGE_TYPES)
      tmp_file = set_tmp_file_path(file_type, obj_with_image)
      IO.copy_stream(download, tmp_file)
      tmp_file
    else
      logger.error("Error downloading file for #{obj_with_image.class.name.downcase} #{obj_with_image.id}: incorrect file type #{file_type}")
      nil
    end
  end

  # Returns the temporary file path for a given file type and object.
  def set_tmp_file_path(file_type, obj_with_image)
    extension = file_type.split(";").first&.split("/")&.last&.split("+")&.first
    "#{Rails.root}/tmp/#{obj_with_image.class.name.downcase}_#{obj_with_image.id}_tmp.#{extension}"
  end

  # Calculates the MD5 hash of the given image file.
  def image_file_md5(image_file)
    Digest::MD5.file(image_file).hexdigest
  end

  # Processes the image file: converts to PNG (unless SVG), resizes, and returns the output file path.
  def process_image_file(tmp_file, avatar_file_path)
    if tmp_file.end_with?(".svg")
      avatar_file = "#{avatar_file_path}.svg"
      FileUtils.cp(tmp_file, avatar_file)
      return avatar_file
    else
      avatar_file = "#{avatar_file_path}.png"
      ImageProcessing::MiniMagick.source(tmp_file)
                                 .convert("png")
                                 .resize_to_limit(*IMAGE_SIZE_LIMIT)
                                 .call(destination: avatar_file)
      return avatar_file
    end
  rescue ImageProcessing::Error => e
    # Skips animated gifs processing
    return if MiniMagick::Image.new(tmp_file).pages.count > 1
    raise e
  end

  # Processes and saves the image, logging the result. Returns the file path or nil on error.
  def process_and_save_image(tmp_file, avatar_file_path, logger)
    begin
      avatar_file = process_image_file(tmp_file, avatar_file_path)
    rescue => e
      Appsignal.send_error(e)
    end

    if avatar_file && File.exist?(avatar_file)
      logger.info("Prepared file to attach: " + avatar_file)
      avatar_file
    else
      logger.error("Error preparing file to attach: " + avatar_file_path)
      nil
    end
  end
end

