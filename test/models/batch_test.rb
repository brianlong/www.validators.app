# frozen_string_literal: true

require 'test_helper'

class BatchTest < ActiveSupport::TestCase
  test 'create a new record with a UUID' do
    batch = Batch.create
    assert_not_nil batch.uuid
    assert batch.uuid.include?('-')
  end

  test 'touch will change the updated_at column' do
    batch = Batch.create
    assert_equal batch.created_at, batch.updated_at
    sleep(2)
    batch.touch
    batch.reload
    assert_not_equal batch.created_at, batch.updated_at
    assert batch.updated_at > batch.created_at
  end
end
