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

  def set_score_class(score)
    if score == -2
      'text-danger'
    else
      'text-warning'
    end
  end

  def set_chart_y_scale(count)
    if count < 60
      count
    else
      60
    end
  end
end
