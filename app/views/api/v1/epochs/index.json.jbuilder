# frozen_string_literal: true

json.epochs @epoch_list,
            partial: 'api/v1/epochs/epoch_wall_clock',
            as: :epoch

json.epochs_count @total
