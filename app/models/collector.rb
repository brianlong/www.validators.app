# frozen_string_literal: true

# The Collector model is used to receive JSON payloads through a data collector
# API. We will not parse the JSON while creating a record -- that could leave us
# open to DoS attacks. Instead, we will insert the payload into this table and
# then validate one record at a time in a background job.
class Collector < ApplicationRecord
  validates :payload_type, presence: true
  validates :payload_version, presence: true
  validates :payload, presence: true
end
