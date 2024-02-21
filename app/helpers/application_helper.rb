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
end
