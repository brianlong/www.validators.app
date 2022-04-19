# frozen_string_literal: true

# The Collector model is used to receive JSON payloads through a data collector
# API. We will not parse the JSON while creating a record -- that could leave us
# open to DoS attacks. Instead, we will insert the payload into this table and
# then validate one record at a time in a background job.

# == Schema Information
#
# Table name: collectors
#
#  id              :bigint           not null, primary key
#  ip_address      :string(191)
#  payload         :text(4294967295)
#  payload_type    :string(191)
#  payload_version :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :bigint           not null
#
# Indexes
#
#  index_collectors_on_user_id  (user_id)
#
class Collector < ApplicationRecord
  validates :payload_type, presence: true
  validates :payload_version, presence: true
  validates :payload, presence: true
end
