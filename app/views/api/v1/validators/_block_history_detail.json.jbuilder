# frozen_string_literal: true

# Extract the base attributes
json.extract! block_history,
              :epoch, :leader_slots, :blocks_produced,
              :skipped_slots, :skipped_slot_percent,
              :created_at, :batch_uuid
