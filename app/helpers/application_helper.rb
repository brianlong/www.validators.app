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
      flash_type.to_s
    end
  end

  def flash_message_is_cookie_info(msg)
    msg == t('flash.cookie')
  end

  def shorten_key(pub_key)
    "#{pub_key[0..5]}...#{pub_key[-4..-1]}"
  end

  def lamports_to_sol(lamports)
    lamports / 1_000_000_000
  end

  def software_color_class(software_version)
    return 'text-red' if software_version.nil?
    return 'text-red' if software_version.blank?

    version = ValidatorSoftwareVersion.new(number: software_version, network: params[:network])
    if version.running_latest_or_edge?
      'text-green'
    elsif version.running_latest_minor?
      'text-orange'
    else
      'text-red'
    end
  end
end
