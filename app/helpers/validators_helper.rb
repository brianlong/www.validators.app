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

  def score_class
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

  def current_software_version(batch, network)
    if batch&.software_version.blank?
      network == 'mainnet' ? MAINNET_CLUSTER_VERSION : TESTNET_CLUSTER_VERSION
    else
      batch.software_version
    end
  end

  def skipped_vote_percent(validator, batch)
    if validator.score&.skipped_vote_history && batch.best_skipped_vote
      # Get the last skipped_vote data from history
      skipped_votes_percent = validator.score.skipped_vote_history[-1]
      return unless skipped_votes_percent
      
      # Calculate the distance from the best skipped vote and round
      ((batch.best_skipped_vote - skipped_votes_percent.to_f) * 100.0).round(2)
    else
      nil
    end
  end

  def above_33percent_concentration?(validator)
    validator.stake_concentration_score.negative?
  end

  def sort_software_versions(versions)
    versions.sort_by { |ver| -ver[ver.keys.first]['stake_percent']}
  end
end
