# frozen_string_literal: true

# This is the model for version 1 of our ValidatorScore.
class ValidatorScoreV1 < ApplicationRecord
  belongs_to :validator
end
