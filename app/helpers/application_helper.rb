# frozen_string_literal: true

module ApplicationHelper
  def bootstrap_class_for_flash(flash_type)
    case flash_type
    when 'success'
      'alert-success'
    when 'error'
      'alert-danger'
    when 'alert'
      'alert-warning'
    when 'notice'
      'alert-info'
    else
      'alert-info'
    end
  end

  def flash_message_is_cookie_info(msg)
    msg == t('flash.cookie')
  end

  def lamports_to_sol(lamports)
    lamports.to_f / 1_000_000_000.to_f
  end

  def lamports_as_formatted_sol(lamports)
    return "0.00" unless lamports.is_a?(Numeric)

    sol = lamports_to_sol(lamports)
    ActiveSupport::NumberHelper.number_to_currency(sol, precision: 2, unit: "")
  end

  def software_color_class(software_version)
    return 'text-danger' if software_version.nil?
    return 'text-danger' if software_version.blank?

    begin
      version = ValidatorSoftwareVersion.new(number: software_version, network: params[:network])
    rescue
      return 'text-danger'
    end

    if version.running_latest_or_newer?
      'text-success'
    elsif version.running_latest_major_and_minor_or_newer?
      'text-warning'
    else
      'text-danger'
    end
  end

  def set_speedometer_needle_position(value:, single_range_size:)
    return 0 unless value && single_range_size
    chart_maximum = single_range_size*3 # speedometer has three equal ranges
    value_in_percents = (value / chart_maximum) * 100
    value_in_percents = [value_in_percents, 100].min.round(2)
    return value_in_percents unless (value < 0)
    100 - value_in_percents
  end

  def frontend_config
    {
      assets: asset_paths_config
    }
  end

  private

  def asset_paths_config
    {
      'default-avatar.png' => asset_path('default-avatar.png'),
      'agave.svg' => asset_path('agave.svg'),
      'firedancer.svg' => asset_path('firedancer.svg'),
      'loading.gif' => asset_path('loading.gif'),
      'doublezero.svg' => asset_path('doublezero.svg'),
      'doublezero_legacy.svg' => asset_path('doublezero_legacy.svg'),
      'marinade-logo.svg' => asset_path('marinade-logo.svg'),
      'marinade.png' => asset_path('marinade.png'),
      'jpool-logo.svg' => asset_path('jpool-logo.svg'),
      'jpool.png' => asset_path('jpool.png'),
      'daopool-logo.png' => asset_path('daopool-logo.png'),
      'daopool.png' => asset_path('daopool.png'),
      'blazestake-logo.png' => asset_path('blazestake-logo.png'),
      'blazestake.png' => asset_path('blazestake.png'),
      'jito-logo.svg' => asset_path('jito-logo.svg'),
      'jito.svg' => asset_path('jito.svg'),
      'jito.png' => asset_path('jito.png'),
      'edgevana-logo.svg' => asset_path('edgevana-logo.svg'),
      'edgevana.png' => asset_path('edgevana.png'),
      'aero-logo.svg' => asset_path('aero-logo.svg'),
      'aero.png' => asset_path('aero.png'),
      'shinobi-logo.png' => asset_path('shinobi-logo.png'),
      'shinobi.png' => asset_path('shinobi.png'),
      'vault-logo.png' => asset_path('vault-logo.png'),
      'vault.png' => asset_path('vault.png'),
      'jagpool-logo.png' => asset_path('jagpool-logo.png'),
      'jagpool.png' => asset_path('jagpool.png'),
      'dynosol-logo.png' => asset_path('dynosol-logo.png'),
      'dynosol.png' => asset_path('dynosol.png'),
      'definsol-logo.png' => asset_path('definsol-logo.png'),
      'definsol.png' => asset_path('definsol.png'),
      'lido-logo.svg' => asset_path('lido-logo.svg'),
      'lido.png' => asset_path('lido.png'),
      'socean-logo.svg' => asset_path('socean-logo.svg'),
      'socean.png' => asset_path('socean.png'),
      'zippystake-logo.svg' => asset_path('zippystake-logo.svg'),
      'zippystake.png' => asset_path('zippystake.png')
    }
  end
end
