# frozen_string_literal: true

Rails.application.routes.draw do
  get 'map' , to: 'map#index', as: 'map'
  mount ActionCable.server => '/cable'

  # Default root path
  root to: 'public#home'

  get 'robots.txt', to: 'public#robots'
  get 'sitemap.xml.gz', to: 'public#sitemap'

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
      as: 'data_center',
      constraints: { key: %r{[^\/]+} }

  # Validators
  get 'validators',
      to: 'validators#index',
      as: 'validators'

  get 'trent-mode',
      to: 'validators#trent_mode',
      as: 'trent_mode'

  get 'validators/mainnet/:account', to: redirect('/validators/%{account}?network=mainnet')
  get 'validators/testnet/:account', to: redirect('/validators/%{account}?network=testnet')
  get 'validators/pythnet/:account', to: redirect('/validators/%{account}?network=pythnet')

  get 'validators/:account', to: 'validators#show', as: 'validator'

  get 'validators/:account/vote_accounts/:vote_account', to: 'vote_accounts#show',
                                                         as: 'validator_vote_account'

  get 'you/', to: 'you#index', as: :user_root
  post 'you/regenerate_token', to: 'you#regenerate_token'

  resources :opt_out_requests, path: 'opt-out-requests', only: [:index, :new, :create, :destroy] do
    collection { get 'thank-you' => 'opt_out_requests#thank_you' }
  end

  # SolPrices
  get 'sol-prices', to:'sol_prices#index'

  # Stake Pools
  get 'stake-pools', to: 'stake_accounts#index'

  devise_for :users,  controllers: {
    sessions: 'sessions'
  }

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
    require 'sidekiq_unique_jobs/web'
    mount Sidekiq::Web => '/sidekiq'
  end

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  # Public Controller
  get 'contact-us', to: 'public#contact_us'
  get 'api-documentation',
      to: 'public#api_documentation',
      as: 'api_documentation'
  get 'contact-requests', to: 'contact_requests#index'
  get 'cookie-policy', to: 'public#cookie_policy'
  get 'faq', to: 'public#faq'
  get 'privacy-policy-california', to: 'public#privacy_policy_california'
  get 'privacy-policy', to: 'public#privacy_policy'
  get 'terms-of-use', to: 'public#terms_of_use'
  get 'commission-changes/mainnet/(:validator_id)',
      to: redirect( '/commission-changes/%{validator_id}?network=mainnet'),
      defaults: { validator_id: nil }
  get 'commission-changes/testnet/(:validator_id)',
      to: redirect( '/commission-changes/%{validator_id}?network=testnet'),
      defaults: { validator_id: nil }
  get 'commission-changes/pythnet/(:validator_id)',
      to: redirect( '/commission-changes/%{validator_id}?network=pythnet'),
      defaults: { validator_id: nil }
  get 'commission-changes/(:validator_id)',
      to: 'public#commission_histories',
      as: 'commission_histories'
  get 'authorities-changes/(:vote_account_id)',
      to: 'public#authorities_changes',
      as: 'authorities_changes'
  get 'authorities_changes/(:vote_account_id)',
      defaults: { locale: 'en', network: 'mainnet' },
      to: redirect { |params, _request|
        vote_account_id = params[:vote_account_id].presence
        path = vote_account_id ? "/authorities-changes/#{vote_account_id}" : '/authorities-changes'
        path + "?locale=#{params[:locale]}&network=#{params[:network]}"
      }

  get 'stake-explorer', to: 'explorer_stake_accounts#index', as: 'explorer_stake_accounts'
  get 'stake-explorer/:stake_pubkey', to: 'explorer_stake_accounts#show', as: 'explorer_stake_account'

  post 'saw_cookie_notice', to: 'public#saw_cookie_notice'
  get 'saw_cookie_notice', to: 'public#saw_cookie_notice'
  get "ping-thing", to: "ping_things#index", as: "ping_things"
  get "current-user", to: "users#current_user_info"

  ### API
  namespace :api do
    namespace :v1, defaults: { format: :json } do
      # api_v1_ping GET /api/v1/ping(.:format)
      get 'ping', to: 'api#ping'

      # api_v1_collector POST /api/v1/ping_times/collector(.:format)
      post 'collector', to: 'ping_times#collector', as: 'collector'

      # api_v1_validators GET /api/v1/validators/:network
      get 'validators/:network',
          to: 'validators#index',
          as: 'validators'

      # api_v1_validators GET /api/v1/validators/:network/:account
      get 'validators/:network/:account',
          to: 'validators#show',
          as: 'validator'

      # api_v1_validators_ledger GET /api/v1/validators-ledger/:network/:account
      get 'validators-ledger/:network/:account',
          to: 'validators#show_ledger',
          as: 'validator_ledger'

      # GET /api/v1/validator_block_history/:network/:account
      get 'validator-block-history/:network/:account',
          to: 'validator_block_histories#show',
          as: 'validator_block_history'

      get 'validator_block_history/:network/:account',
          to: 'validator_block_histories#show',
          as: 'validator_block_history_old'

      # Blockchain
      get 'last-blocks/:network',
            to: 'vote#block_list',
            as: 'last_blocks'

      get 'block-votes/:network/:block_hash',
            to: 'vote#block_details',
            as: 'block_votes'

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
      get 'ping-times/:network', to: 'ping_times#ping_times', as: 'ping_times'
      get 'ping-time-stats/:network', to: 'ping_times#ping_time_stats', as: 'ping_time_stats'

      # POST /api/v1/ping-thing/
      post 'ping-thing/:network', to: 'ping_things#create', as: 'ping_thing'
      # POST /api/v1/ping-thing-batch/
      post 'ping-thing-batch/:network', to: 'ping_things#create_batch', as: 'ping_thing_batch'
      # GET /api/v1/ping-thing/
      get 'ping-thing/:network', to: 'ping_things#index', as: 'ping_things'

      get 'ping-thing-stats/:network', to: 'ping_thing_stats#index', as: 'ping_thing_stats'
      get 'ping-thing-recent-stats/:network', to: 'ping_thing_recent_stats#last', as: 'ping_thing_recent_stats'
      get 'ping-thing-user-stats/:network', to: 'ping_thing_user_stats#last', as: 'ping_thing_user_stats'

      get 'sol-prices', to: 'sol_prices#index', as: 'sol_prices'

      post 'update-watchlist/:network', to: 'watchlists#update_watchlist'

      get "gossip-nodes/:network", to: "gossip_nodes#index", as: "gossip_nodes"

      get "data-centers-with-nodes/:network", to: "data_centers#index_with_nodes", as: "data_centers_with_nodes"
      get "data-centers-for-map", to: "data_centers#index_for_map", as: "data_centers_for_map"
      get "data-center-stats/:network", to: "data_centers#data_center_stats", as: "data_center_stats"

      get "account-authorities/:network", to: "account_authority#index", as: "account_authorities"

      get "stake-explorer/:network", to: "explorer_stake_accounts#index", as: "explorer_stake_accounts"
    end
  end
end
