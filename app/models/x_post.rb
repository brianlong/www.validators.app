# frozen_string_literal: true

# == Schema Information
#
# Table name: x_posts
#
#  id            :bigint           not null, primary key
#  error         :text(65535)
#  kind          :string(191)
#  message       :text(65535)
#  metadata      :text(65535)
#  network       :string(191)
#  posted_at     :datetime
#  reference_key :string(191)      not null
#  status        :string(191)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  parent_id     :bigint
#  validator_id  :bigint
#  x_post_id     :string(191)
#
# Indexes
#
#  index_x_posts_on_network_and_kind_and_created_at  (network,kind,created_at)
#  index_x_posts_on_parent_id                        (parent_id)
#  index_x_posts_on_reference_key                    (reference_key) UNIQUE
#  index_x_posts_on_validator_id                     (validator_id)
#
class XPost < ApplicationRecord
  STATUSES = %w[pending posted dry_run failed].freeze

  belongs_to :validator, optional: true
  belongs_to :parent, class_name: "XPost", optional: true
  has_many :replies, class_name: "XPost", foreign_key: :parent_id, dependent: :nullify

  serialize :metadata, JSON

  validates :reference_key, presence: true, uniqueness: true
  validates :status, inclusion: { in: STATUSES }

  scope :not_failed, -> { where.not(status: "failed") }
end
