# frozen_string_literal: true

Rails.application.routes.draw do
  resources :vote_accounts, only: %i[show]

  get 'validators/:network', to: 'validators#index', as: 'validators'
  get 'validators/:network/:account', to: 'validators#show', as: 'validator'

  get 'you/', to: 'you#index', as: :user_root
  post 'you/regenerate_token', to: 'you#regenerate_token'

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

  namespace :api do
    namespace :v1 do
      # api_v1_ping GET /api/v1/ping(.:format)
      get 'ping', to: 'api#ping'
      # api_v1_collector POST /api/v1/collector
      post 'collector', to: 'api#collector'
      # api_v1_validators GET /api/v1/validators/:network
      get 'validators/:network', to: 'api#validators_list'
      # api_v1_validators GET /api/v1/validators/:network/:account
      get 'validators/:network/:account',
          to: 'api#validators_show',
          as: 'validator'
    end
  end

  # Public Controller
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
