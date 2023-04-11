# frozen_string_literal: true

# Extract the base attributes
json.extract! block_history, *ValidatorBlockHistory::API_FIELDS
