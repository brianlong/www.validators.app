#frozen_string_literal: true

module AvatarAttachment
  extend ActiveSupport::Concern

  included do
    has_one_attached :avatar
    validate :avatar_type
  end

  def avatar_type
    if avatar.attached? && !avatar.content_type.in?(%w(image/png image/gif))
      errors.add(:avatar, "must be PNG or GIF")
    end
  end

  def avatar_core_name
    self.account + "_" + self.network
  end

  def avatar_file_name(gif: false)
    extension = gif ? ".gif" : ".png"
    avatar_core_name + extension
  end

  def avatar_tmp_file_name(gif: false)
    extension = gif ? ".gif" : ".png"
    avatar_core_name + "_tmp" + extension
  end
end
