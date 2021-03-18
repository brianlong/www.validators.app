module ValidatorsHelper
  def set_chart_line_color(score)
    if score == 2
      GREEN
    elsif score == 1
      BLUE
    else
      LIGHT_GREY
    end
  end

  def set_chart_fill_color(score)
    if score == 2
      GREEN_TRANSPARENT
    elsif score == 1
      BLUE_TRANSPARENT
    else
      LIGHT_GREY_TRANSPARENT
    end
  end

  def set_score_class(score)
    if score == -2
      'text-danger'
    else
      'text-warning'
    end
  end

  def set_chart_x_scale(count)
    if count < X_SCALE_MAX
      count
    else
      X_SCALE_MAX
    end
  end

  def set_max_value_position(vector)
    max_value = vector.max
    max_value_index = vector.index(max_value) + 1
    position = max_value_index.to_f / vector.size * 100
    position = position + 4
    position = [position, 100].min # rejects values larger than 100
    position = [position, 12].max # rejects values smaller than 12
    number_to_percentage(position, precision: 0)
  end
end
