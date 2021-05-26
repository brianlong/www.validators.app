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

  def current_software_version(batch, network)
    if batch.software_version.blank?
      network == 'mainnet' ? MAINNET_CLUSTER_VERSION : TESTNET_CLUSTER_VERSION
    else
      batch.software_version
    end
  end

  def skipped_vote_percent(validator, batch)
    vahl = validator.vote_account_last&.vote_account_history_for(batch.uuid)
    if vahl
      skipped_votes_percent = (vahl.slot_index_current.to_i - vahl.credits_current.to_i)/vahl.slot_index_current.to_f
      skipped_vote_displayed = ((@skipped_vote_percent_best - skipped_votes_percent.to_f)*100.0).round(2)
    else
      nil
    end
  end
end
