# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users

  # Free Sidekiq
  if Gem.loaded_specs.key? 'sidekiq'
    require 'sidekiq'
    require 'sidekiq/web'
  end

  # Sidekiq Pro
  # if Gem.loaded_specs.key? 'sidekiq-pro'
  #   require 'sidekiq-pro'
  #   require 'sidekiq/pro/web'
  # end

  # Only admins can see the Sidekiq Dashboard
  authenticate :user, ->(u) { u.is_admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  # Public Controller
  # get 'public/index'
  match 'contact-us', to: 'public#contact_us', via: %i[get post]

  get 'contact-requests', to: 'contact_requests#index'
  get 'cookie-policy', to: 'public#cookie_policy'
  get '/do-not-sell-my-personal-information/',
      to: 'public#do_not_sell_my_personal_information',
      as: :do_not_sell_my_personal_information
  get 'faq', to: 'public#faq'
  get 'privacy-policy-california', to: 'public#privacy_policy_california'
  get 'privacy-policy', to: 'public#privacy_policy'
  get 'terms-of-use', to: 'public#terms_of_use'
  post 'saw_cookie_notice', to: 'public#saw_cookie_notice'

  # Default root path
  root to: 'public#index'
end
