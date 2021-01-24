# frozen_string_literal: true

json.array! @block_history,
            partial: 'api/v1/validators/block_history_detail',
            as: :block_history
