#frozen_string_literal: true

module ImageAttachment
  extend ActiveSupport::Concern

  IMAGE_TYPES = %w[image/png image/svg+xml image/jpg image/jpeg].freeze

  included do
    has_one_attached :image
    validate :image_type
  end

  def image_type
    if image.attached? && !image.content_type.in?(%w(image/png image/svg+xml image/jpg image/jpeg))
      errors.add(:image, 'must be PNG, SVG, JPG, or JPEG file type')
    end
  end

  def image_file_name
    self.pubkey + "_" + self.network
  end

  def image_tmp_file_name
    self.pubkey + "_" + self.network + "_tmp"
  end
end
