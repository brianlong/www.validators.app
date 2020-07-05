# frozen_string_literal: true

# Holds the data for the feed zone
class FeedZone < ApplicationRecord
  serialize :payload, JSON
end
