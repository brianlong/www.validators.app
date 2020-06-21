# frozen_string_literal: true

json.array! @validators, partial: 'api/v1/validators/validator', as: :validator
