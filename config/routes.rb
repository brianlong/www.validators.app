# frozen_string_literal: true

Rails.application.routes.draw do
  get 'asns/:asn',
      to: 'asns#show',
      as: 'asn'
  # Pages for Log Deep Dives
  get 'log-deep-dives/',
      to: 'log_deep_dives#index',
      as: 'log_deep_dives_index'

  get 'log-deep-dives/slot-72677728',
      to: 'log_deep_dives#slot_72677728',
      as: 'log_deep_dives_slot_72677728'

  # Data Centers
  get 'data-centers',
      to: 'data_centers#index',
      as: 'data_centers'
  get 'data-centers/:key',
      to: 'data_centers#data_center',
      as: 'data_center'

  get 'vote_accounts/:account',
      to: 'vote_accounts#show',
      as: 'vote_account'

  # Validators
  get 'validators',
      to: 'validators#index',
      as: 'validators'
  get 'validators-v2',
      to: 'validators#index_v2',
      as: 'validators_v2'
  get 'validators/mainnet/:account', to: redirect('/validators/%{account}?network=mainnet')
  get 'validators/testnet/:account', to: redirect('/validators/%{account}?network=testnet')
  get 'validators/:account',
      to: 'validators#show',
      as: 'validator'

  get 'tower',
      to: 'public#tower',
      as: 'tower'

  get 'you/', to: 'you#index', as: :user_root
  post 'you/regenerate_token', to: 'you#regenerate_token'

  resources :opt_out_requests, path: 'opt-out-requests', only: [:index, :new, :create, :destroy] do
    collection { get 'thank-you' => 'opt_out_requests#thank_you' }
  end

  # SolPrices
  get 'sol_prices', to:'sol_prices#index'

  # Stake Pools
  get 'stake-pools', to: 'stake_accounts#index'

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
  get 'contact-us', to: 'public#contact_us'
  get 'stake-boss', to: 'public#stake_boss', as: 'stake_boss'
  get 'api-documentation',
      to: 'public#api_documentation',
      as: 'api_documentation'
  get 'contact-requests', to: 'contact_requests#index'
  get 'cookie-policy', to: 'public#cookie_policy'
  get 'faq', to: 'public#faq'
  get 'privacy-policy-california', to: 'public#privacy_policy_california'
  get 'privacy-policy', to: 'public#privacy_policy'
  get 'sample-chart', to: 'public#sample_chart'
  get 'terms-of-use', to: 'public#terms_of_use'
  get 'commission-changes/mainnet/(:validator_id)',
      to: redirect( '/commission-changes/%{validator_id}?network=mainnet'),
      defaults: { validator_id: nil }
  get 'commission-changes/testnet/(:validator_id)',
      to: redirect( '/commission-changes/%{validator_id}?network=testnet'),
      defaults: { validator_id: nil }
  get 'commission-changes/(:validator_id)',
      to: 'public#commission_histories',
      as: 'commission_histories'

  get 'cluster-stats',
      to: 'cluster_stats#index',
      as: 'cluster_stats'

  post 'saw_cookie_notice', to: 'public#saw_cookie_notice'
  get 'saw_cookie_notice', to: 'public#saw_cookie_notice'
  get "ping-thing", to: "ping_things#index", as: "ping_things"

  # Default root path
  root to: 'validators#index'

  ### API
  namespace :api do
    namespace :v1, defaults: { format: :json } do
      # api_v1_ping GET /api/v1/ping(.:format)
      get 'ping', to: 'api#ping'

      # TODO to remove - endpoint no longer in use
      # api_v1_collector POST /api/v1/collector
      post 'collector', to: 'api#collector'

      # api_v1_validators GET /api/v1/validators/:network
      get 'validators/:network',
          to: 'validators#index',
          as: 'validators'

      # api_v1_validators GET /api/v1/validators/:network/:account
      get 'validators/:network/:account',
          to: 'validators#show',
          as: 'validator'

      # GET /api/v1/validator_block_history/:network/:account
      get 'validator-block-history/:network/:account',
          to: 'validator_block_histories#show',
          as: 'validator_block_history'

      get 'validator_block_history/:network/:account',
          to: 'validator_block_histories#show',
          as: 'validator_block_history_old'

      # Epoch Wall Clock
      get 'epochs/:network', to: 'epochs#index', as: 'epoch_index'

      # GET /api/v1/commission-changes/:network
      get 'commission-changes/:network', to: 'commission_histories#index', as: 'commission_histories_index'

      # GET /api/v1/stake-accounts/:network
      get 'stake-accounts/:network', to: 'stake_accounts#index', as: 'stake_accounts_index'

      # GET /api/v1/stake-pools/:network
      get 'stake-pools/:network', to: 'stake_pools#index', as: 'stake_pools_index'

      # TODO to remove - endpoint no longer in use
      # api_v1_ping_times GET /api/v1/ping_times
      get 'ping-times/:network', to: 'api#ping_times', as: 'ping_times'

      # POST /api/v1/ping-thing/
      post 'ping-thing/:network', to: 'ping_things#create', as: 'ping_thing'
      # POST /api/v1/ping-thing-batch/
      post 'ping-thing-batch/:network', to: 'ping_things#create_batch', as: 'ping_thing_batch'
      # GET /api/v1/ping-thing/
      get 'ping-thing/:network', to: 'ping_things#index', as: 'ping_things'

      get 'sol-prices', to: 'sol_prices#index', as: 'sol_prices'
    end
  end
end
