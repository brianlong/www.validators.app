# frozen_string_literal: true

# ApplicationController
class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  around_action :switch_locale
  before_action :check_if_saw_cookie_notice
  before_action :set_network

  def switch_locale(&action)
    locale = params[:locale] || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  # app/controllers/application_controller.rb
  def default_url_options
    network = params[:network] ||= 'mainnet'
    { locale: I18n.locale, network: network }
  end

  def check_if_saw_cookie_notice
    flash[:cookie_notice] = t('flash.cookie').html_safe \
      unless cookies[:saw_cookie_notice]
  end

  def saw_cookie_notice
    cookies[:saw_cookie_notice] = true
    flash.delete(:cookie_notice)
    redirect_back(fallback_location: root_path)
  end

  def set_network
    return if params[:network].present? && NETWORKS.include?(params[:network])

    params[:network] = "mainnet"
  end

  protected

  def configure_permitted_parameters
    added_attrs = %i[username email password password_confirmation remember_me]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
  end

  def not_found
    raise ActiveRecord::RecordNotFound, status: 404
  end

  def render_404
    render file: Rails.root.join('public/404.html'), layout: nil, status: 404
  end
end
