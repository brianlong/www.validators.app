# frozen_string_literal: true

# VoteAccount
class VoteAccount < ApplicationRecord
  belongs_to :validator
  has_many :votes
end
