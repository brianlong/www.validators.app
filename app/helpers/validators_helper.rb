module ValidatorsHelper
  def set_chart_line_color(score)
    return GREEN if score == 2
    return BLUE if score == 1
    LIGHT_GREY
  end

  def set_chart_fill_color(score)
    return GREEN_TRANSPARENT if score == 2
    return BLUE_TRANSPARENT if score == 1
    LIGHT_GREY_TRANSPARENT
  end

  def set_score_class(score)
    return 'text-danger' if score == -2
    'text-warning'
  end

  def set_chart_x_scale(count)
    [X_SCALE_MAX, count].min
  end

  def set_max_value_position(vector, min_position = true)
    max_value = vector.max
    max_value_index = vector.index(max_value) + 1
    position = max_value_index.to_f / vector.size * 100
    position = position + 3
    position = [position, 100].min # rejects values larger than 100
    if min_position
      position = [position, 11].max # rejects values smaller than 11
    end
    number_to_percentage(position, precision: 0)
  end
end
