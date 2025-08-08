#frozen_string_literal: true

TMP_STORAGE_PATH = Rails.root.join("tmp").to_s.freeze
LOG_PATH = Rails.root.join("log", "update_image_file_service.log").to_s.freeze

IMAGE_TYPES = %w[image/png image/gif image/jpeg image/webp image/avif image/svg+xml image/bmp].freeze

class UpdateImageFileService
  include ImageProcessingHelper

  def initialize(object_with_image, asset_name)
    @object_with_image = object_with_image
    @logger = Logger.new(LOG_PATH)
    @tmp_file = nil
    @image_file = nil
    @asset_name = asset_name.to_s
  end

  def call(keep_tmp_files: false)
    return unless @object_with_image.send("#{@asset_name}_url").present?

    if @tmp_file = download_tmp_file("#{@asset_name}_url", @object_with_image)
      if @object_with_image.send("#{@asset_name}_hash") != image_file_md5(@tmp_file)
        @logger.info("Found new image for object: " + @object_with_image.id.to_s)

        @image_file_path = TMP_STORAGE_PATH + "/" + @object_with_image.send("#{@asset_name}_file_name")

        if @image_file = process_and_save_image(@tmp_file, @image_file_path, @logger)
          update_attached_image
          @object_with_image.send("#{@asset_name}_hash=", image_file_md5(@tmp_file))
          @object_with_image.save
        end
      end
      purge_files(keep_tmp_files)
    end
  end

  def update_attached_image
    @object_with_image.send(@asset_name).purge
    @logger.info("Purged old image for object: " + @object_with_image.id.to_s)
    @object_with_image.send(@asset_name).attach(io: File.open(@image_file), filename: @object_with_image.send("#{@asset_name}_file_name"))
    @logger.info("Attached new image for object: " + @object_with_image.id.to_s)
  end

  def purge_files(keep_tmp_files)
    unless keep_tmp_files
      Dir[TMP_STORAGE_PATH + "/*_#{@object_with_image.network}*"].entries.each do |file|
        File.delete(file)
        @logger.info("Deleted file: " + file)
      end
    end
  end
end
