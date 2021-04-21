# frozen_string_literal: true

Rails.application.routes.draw do
  # Pages for Log Deep Dives
  get 'log-deep-dives/',
      to: 'log_deep_dives#index',
      as: 'log_deep_dives_index'

  get 'log-deep-dives/slot-72677728',
      to: 'log_deep_dives#slot_72677728',
      as: 'log_deep_dives_slot_72677728'

  # Data Centers
  get 'data-centers/:network',
      to: 'data_centers#index',
      as: 'data_centers'
  get 'data-centers/:network/:key',
      to: 'data_centers#data_center',
      as: 'data_center'

  get 'vote_accounts/:network/:account',
      to: 'vote_accounts#show',
      as: 'vote_account'

  # Validators
  get 'validators/:network',
      to: 'validators#index',
      as: 'validators'
  get 'validators/:network/:account',
      to: 'validators#show',
      as: 'validator'

  get 'tower/:network',
      to: 'public#tower',
      as: 'tower'

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
    namespace :v1, defaults: { format: :json } do
      # api_v1_ping GET /api/v1/ping(.:format)
      get 'ping', to: 'api#ping'

      # api_v1_ping_times GET /api/v1/ping_times
      get 'ping-times/:network', to: 'api#ping_times', as: 'ping_times'

      # api_v1_collector POST /api/v1/collector
      post 'collector', to: 'api#collector'

      # api_v1_validators GET /api/v1/validators/:network
      get 'validators/:network',
          to: 'api#validators_list',
          as: 'validators'

      # api_v1_validators GET /api/v1/validators/:network/:account
      get 'validators/:network/:account',
          to: 'api#validators_show',
          as: 'validator'

      get 'validator_block_history/:network/:account',
          to: 'api#validator_block_history',
          as: 'validator_block_history'

      # Epoch Wall Clock
      get 'epoch/:network/last', 
          to: 'epochs#last',
          as: 'epoch_last'
      get 'epoch/:network/index', 
          to: 'epochs#index',
          as: 'epoch_index'
    end
  end

  # Public Controller
  get 'contact-us', to: 'public#contact_us'

  get 'stake-boss', to: 'public#stake_boss', as: 'stake_boss'

  get 'api-documentation',
      to: 'public#api_documentation',
      as: 'api_documentation'
  get 'contact-requests', to: 'contact_requests#index'
  get 'cookie-policy', to: 'public#cookie_policy'
  get '/do-not-sell-my-personal-information/',
      to: 'public#do_not_sell_my_personal_information',
      as: :do_not_sell_my_personal_information
  get 'faq', to: 'public#faq'
  get 'privacy-policy-california', to: 'public#privacy_policy_california'
  get 'privacy-policy', to: 'public#privacy_policy'
  get 'sample-chart', to: 'public#sample_chart'
  get 'terms-of-use', to: 'public#terms_of_use'

  post 'saw_cookie_notice', to: 'public#saw_cookie_notice'

  # Default root path
  root to: 'public#index'
end
