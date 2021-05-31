module ValidatorsHelper
  def chart_line_color(score)
    return GREEN if score == 2

    return BLUE if score == 1

    LIGHT_GREY
  end

  def chart_fill_color(score)
    return GREEN_TRANSPARENT if score == 2

    return BLUE_TRANSPARENT if score == 1

    LIGHT_GREY_TRANSPARENT
  end

  def score_class(score)
    return 'text-danger' if score == -2

    'text-warning'
  end

  def chart_x_scale(count)
    [X_SCALE_MAX, count].min
  end

  def max_value_position(vector, min_position: true)
    max_value = vector.max
    max_value_index = vector.index(max_value) + 1
    position = max_value_index.to_f / vector.size * 100
    position += 3
    position = [position, 100].min # rejects values larger than 100
    if min_position
      position = [position, 11].max # rejects values smaller than 11
    end
    number_to_percentage(position, precision: 0)
  end

  def display_avatar(validator)
    if validator&.avatar_url
      image_tag validator.avatar_url, class: 'img-circle mb-1'
    else
      image_tag 'https://keybase.io/images/no-photo/placeholder-avatar-180-x-180@2x.png',
                class: 'img-circle mb-1'
    end
  end

  def percent_of_total_stake(active_stake, total_stake)
    number_to_percentage((active_stake / total_stake.to_f) * 100.0, precision: 2)
  end
end
