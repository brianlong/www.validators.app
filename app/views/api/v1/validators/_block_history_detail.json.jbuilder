# frozen_string_literal: true

# Extract the base attributes
json.extract! block_history, *ValidatorBlockHistory::FIELDS_FOR_API
