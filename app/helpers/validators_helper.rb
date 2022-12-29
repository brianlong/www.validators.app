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

  def max_value_position(vector)
    max_value = vector.max
    max_value_index = vector.index(max_value)
    position = max_value_index.to_f / vector.size * 100
    position = [position, 2].max
    # set max position for large numbers
    if max_value > 100_000
      position = [position, 70].min
    elsif max_value > 10_000
      position = [position, 80].min
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
    return CLUSTER_VERSION[network] if batch&.software_version.blank?

    batch&.software_version
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

  def sort_software_versions(versions)
    versions&.sort_by { |ver| Gem::Version.new(ver.keys.first)}&.reverse
  end

  def solstake_url(vote_account)
    "https://solstake.io/#/app/validator/#{vote_account}"
  end

  def staking_kiwi_url(vote_account)
    "https://staking.kiwi/app/#{vote_account}"
  end

  def blazestake_url(vote_account)
    "https://stake.solblaze.org/app/?validator=#{vote_account}"
  end

  def shuffle_logos
    [
      ["https://lido.fi/solana", "lido.png"],
      ["https://marinade.finance", "marinade.png"],
      ["https://www.socean.fi", "socean.png"],
      ["https://jpool.one", "jpool.png"],
      ["https://daopool.monkedao.io", "daopool.png"],
      ["https://eversol.one/", "eversol.png"],
      ["https://stake.solblaze.org/", "blazestake.png"],
      ["https://www.jito.network/", "jito.png"]
      # add more stake pools here
    ].shuffle
  end

  def link_to_validator_website(url)
    return '' unless url.present?

    if url.start_with?('https', 'http')
      link_to url, url, target: 'blank'
    else
      url
    end
  end

  def create_avatar_link(validator)
    link_params = {
      network: params[:network],
      account: validator.account,
      order: params[:order],
      page: params[:page],
      refresh: params[:refresh]
    }

    if validator.private_validator?
      link_to validator_url(link_params) do
        content_tag :div,
                    content_tag(:span, nil, class: "fa-solid fa-users-slash", title: "Private Validator"),
                    class: "img-circle-medium-private"
      end
    elsif validator.avatar_url
      link_to validator_url(link_params) do
        image_tag validator.avatar_url, class: 'img-circle-medium'
      end
    else
      link_to validator_url(link_params) do
        image_tag 'https://keybase.io/images/no-photo/placeholder-avatar-180-x-180@2x.png', class: 'img-circle-medium'
      end
    end
  end
end
