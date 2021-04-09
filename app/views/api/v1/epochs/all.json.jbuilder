# frozen_string_literal: true

json.array! @epoch_list, partial: 'api/v1/epochs/epoch_wall_clock', as: :epoch