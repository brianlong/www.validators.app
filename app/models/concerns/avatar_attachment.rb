#frozen_string_literal: true

module AvatarAttachment
  extend ActiveSupport::Concern

  included do
    has_one_attached :avatar
    validate :avatar_type
  end

  def avatar_type
    if avatar.attached? && !avatar.content_type.in?(%w(image/png image/svg+xml))
      errors.add(:avatar, 'must be PNG or SVG file type')
    end
  end

  def avatar_file_name
    self.account + "_" + self.network
  end

  def avatar_tmp_file_name
    self.account + "_" + self.network + "_tmp"
  end
end
