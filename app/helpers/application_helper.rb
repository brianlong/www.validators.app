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

  def validator_display_name(validator)
    if validator.private_validator? && !validator.lido?
      'Private Validator'
    else
      validator.name || shorten_key(validator.account)
    end
  end

  def shorten_key(pub_key)
    "#{pub_key[0..5]}...#{pub_key[-4..-1]}"
  end

  def lamports_to_sol(lamports)
    lamports / 1_000_000_000.to_f
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

  def transaction_type_icon(transaction_type_string)
    case transaction_type_string
    when "transfer"
      '<i class="fas fa-exchange-alt text-success mr-1"></i>'
    else
      '<i class="fas fa-random text-success mr-1"></i>'
    end
  end
end
