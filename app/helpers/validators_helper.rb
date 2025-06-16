module ValidatorsHelper
  def displayed_validator_name(validator)
    return "Private Validator" if validator.private_validator?
    return shorten_key(validator.name) if validator.name == validator.account

    validator.name || shorten_key(validator.account)
  end

  def displayed_validator_commission(validator)
    unless validator.private_validator?
      commission_tag = "<span class='d-inline-block d-lg-none'>Comm.:&nbsp;</span>"
      "<small class='text-muted text-nowrap fw-normal'>(#{commission_tag}#{validator.commission}%)</small>".html_safe
    end
  end

  def shorten_key(pub_key)
    "#{pub_key[0..5]}...#{pub_key[-4..-1]}"
  end

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

  def percent_of_total_stake(active_stake, total_stake)
    number_to_percentage((active_stake / total_stake.to_f) * 100.0, precision: 2)
  end

  def skipped_vote_percent(validator, batch)
    if validator.score&.skipped_vote_history && batch.best_skipped_vote
      # Get the last skipped_vote data from history
      skipped_votes_percent = validator.score.skipped_vote_history[-1]
      return unless skipped_votes_percent

      # Calculate the distance from the best skipped vote (vote credit) and round
      ((batch.best_skipped_vote - skipped_votes_percent.to_f) * 100.0).round(2)
    else
      nil
    end
  end

  def sort_software_versions(versions)
    versions&.sort_by { |ver| ver.values[0]["stake_percent"] }&.reverse
  end

  def link_to_validator_website(url)
    return "" unless url.present?

    if url.start_with?("https", "http")
      link_to url, url, target: "blank"
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
                    class: "img-circle-large-private"
      end
    elsif validator.avatar.attached?
      url = Rails.env.in?(["stage", "production"]) ? validator.avatar.url : validator.avatar
      link_to validator_url(link_params) do
        image_tag url, class: "img-circle-large"
      end
    else
      link_to validator_url(link_params) do
        image_tag "default-avatar.png", class: "img-circle-large"
      end
    end
  end

  def validator_score_attrs(validator)
    validator.to_json(
      methods: [
        :root_distance_score, :vote_distance_score, :skipped_slot_score,
        :published_information_score, :software_version_score,
        :security_report_score, :stake_concentration_score,
        :data_center_concentration_score, :authorized_withdrawer_score,
        :consensus_mods_score
      ],
      only: :account,
      include: [
        score: { methods: :displayed_total_score, only: [] }
      ]
    )
  end

  def validators_reset_action(trent_mode = false)
    trent_mode ? :trent_mode : :index
  end
end
