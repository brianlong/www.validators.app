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

  def chart_x_scale(count)
    [X_SCALE_MAX, count].min
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

  def set_iterator(params, items_per_page)
    items_per_page = Kaminari.config.default_per_page unless items_per_page
    return 0 if params[:page].nil? || params[:page].empty? || params[:page].to_i.zero?
    (params[:page].to_i - 1) * items_per_page
  end
end
