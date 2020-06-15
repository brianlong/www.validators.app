# frozen_string_literal: true

# The Report model will hold pre-compiled reports
class Report < ApplicationRecord
  serialize :payload, JSON
end
