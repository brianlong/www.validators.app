# frozen_string_literal: true

require "test_helper"

module Blockchain
  class SetVoteLatencyScoreTest < ActiveSupport::TestCase

    setup do
      @validator = create(:validator, :with_score)
    end


  end
end
