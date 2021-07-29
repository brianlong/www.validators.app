# frozen_string_literal: true

json.commission_changes @commission_histories,
                        partial: '/api/v1/commission_histories/commission_history',
                        as: :commission_history
