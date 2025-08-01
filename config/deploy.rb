# frozen_string_literal: true

# config valid for current version and patch releases of Capistrano
lock '~> 3.16.0'

set :application, 'validators.app'
set :repo_url, 'git@github.com:brianlong/www.validators.app.git'
set :user, 'deploy'

# Default branch is :master
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"
set :deploy_to, "/home/deploy/#{fetch(:application)}"

set :migration_role, :db
set :templated_config_files, []

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true
set :pty, false

set :sitemap_roles, :web

# Default value for :linked_files is []
append :linked_files, 'config/database.yml'
# Note: Each server contains both keys, but the non-essential key is blank.
append :linked_files, 'config/credentials/production.key'
append :linked_files, 'config/credentials/stage.key'
append :linked_files, 'config/appsignal.yml'
append :linked_files, 'config/sidekiq.yml'
append :linked_files, 'config/sidekiq_blockchain.yml'
append :linked_files, 'config/cluster.yml'
append :linked_files, '.env'

# Default value for linked_dirs is []
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system'

set :bundle_dir, '/home/deploy/gems'
set :default_env, {
  'GEM_HOME' => '/home/deploy/gems',
  'GEM_PATH' => '/home/deploy/gems'
}

set :passenger_environment_variables, { path: '/usr/sbin/passenger-status:$PATH' }
# set :passenger_restart_with_touch, true
set :passenger_roles, :web

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

# Whenever/crontab config. Updates crontab on all servers with this role.
# Selects cron tasks by roles defined in config/schedule.rb
set :whenever_roles, ["cron"]

namespace :deploy do
  after :restart, 'sidekiq:restart'
  after :restart, 'rake_task:add_stake_pools'
  after :restart, 'sitemap:create'
  after :restart, 'deamons:restart'
end

namespace :sidekiq do
  desc 'Stop sidekiq (put unfinished tasks back to Redis)'
  task :stop do
    on roles :background do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :systemctl, '--user', :stop, :sidekiq
        end
      end
    end
    on roles :sidekiq_blockchain do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :systemctl, '--user', :stop, :sidekiq_blockchain
        end
      end
    end
  end

  desc 'Start sidekiq'
  task :start do
    on roles :background do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :systemctl, '--user', :start, :sidekiq
        end
      end
    end
    on roles :sidekiq_blockchain do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :systemctl, '--user', :start, :sidekiq_blockchain
        end
      end
    end
  end

  desc 'Restart sidekiq'
  task :restart do
    on roles :background do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :systemctl, '--user', :restart, :sidekiq
        end
      end
    end
    on roles :sidekiq_blockchain do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :systemctl, '--user', :restart, :sidekiq_blockchain
        end
      end
    end
  end
end

namespace :deamons do
  desc 'Start background'
  task :start do
    on roles :background do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :systemctl, '--user', :start, :validator_score_mainnet_v1
          execute :systemctl, '--user', :start, :validator_score_testnet_v1
          execute :systemctl, '--user', :start, :validator_score_pythnet_v1
          execute :systemctl, '--user', :start, :gather_rpc_mainnet
          execute :systemctl, '--user', :start, :gather_rpc_testnet
          execute :systemctl, '--user', :start, :gather_rpc_pythnet
          execute :systemctl, '--user', :start, :gather_vote_account_details
          execute :systemctl, '--user', :start, :process_ping_thing
          execute :systemctl, '--user', :start, :front_stats_update
          execute :systemctl, '--user', :start, :leader_stats_mainnet_update
          execute :systemctl, '--user', :start, :leader_stats_testnet_update
          execute :systemctl, '--user', :start, :leader_stats_pythnet_update
        end
      end
    end
    on roles :background_production do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :systemctl, '--user', :start, :slot_subscribe_mainnet
          # execute :systemctl, '--user', :start, :slot_subscribe_testnet
          # execute :systemctl, '--user', :start, :slot_subscribe_pythnet
          execute :systemctl, '--user', :start, :archive_blockchain_mainnet
          # execute :systemctl, '--user', :start, :archive_blockchain_testnet
          # execute :systemctl, '--user', :start, :archive_blockchain_pythnet
        end
      end
    end
  end

  desc 'Stop background'
  task :stop do
    on roles :background do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :systemctl, '--user', :stop, :validator_score_mainnet_v1
          execute :systemctl, '--user', :stop, :validator_score_testnet_v1
          execute :systemctl, '--user', :stop, :validator_score_pythnet_v1
          execute :systemctl, '--user', :stop, :gather_rpc_mainnet
          execute :systemctl, '--user', :stop, :gather_rpc_testnet
          execute :systemctl, '--user', :stop, :gather_rpc_pythnet
          execute :systemctl, '--user', :stop, :gather_vote_account_details
          execute :systemctl, '--user', :stop, :process_ping_thing
          execute :systemctl, '--user', :stop, :front_stats_update
          execute :systemctl, '--user', :stop, :leader_stats_mainnet_update
          execute :systemctl, '--user', :stop, :leader_stats_testnet_update
          execute :systemctl, '--user', :stop, :leader_stats_pythnet_update
        end
      end
    end
    on roles :background_production do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :systemctl, '--user', :stop, :slot_subscribe_mainnet
          # execute :systemctl, '--user', :stop, :slot_subscribe_testnet
          # execute :systemctl, '--user', :stop, :slot_subscribe_pythnet
          execute :systemctl, '--user', :stop, :archive_blockchain_mainnet
          # execute :systemctl, '--user', :stop, :archive_blockchain_testnet
          # execute :systemctl, '--user', :stop, :archive_blockchain_pythnet
        end
      end
    end
  end

  desc 'Restart background'
  task :restart do
    on roles :background do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :systemctl, '--user', :restart, :validator_score_mainnet_v1
          execute :systemctl, '--user', :restart, :validator_score_testnet_v1
          execute :systemctl, '--user', :restart, :validator_score_pythnet_v1
          execute :systemctl, '--user', :restart, :gather_rpc_mainnet
          execute :systemctl, '--user', :restart, :gather_rpc_testnet
          execute :systemctl, '--user', :restart, :gather_rpc_pythnet
          execute :systemctl, '--user', :restart, :gather_vote_account_details
          execute :systemctl, '--user', :restart, :process_ping_thing
          execute :systemctl, '--user', :restart, :front_stats_update
          execute :systemctl, '--user', :restart, :leader_stats_mainnet_update
          execute :systemctl, '--user', :restart, :leader_stats_testnet_update
          execute :systemctl, '--user', :restart, :leader_stats_pythnet_update
        end
      end
    end
    on roles :background_production do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :systemctl, '--user', :restart, :slot_subscribe_mainnet
          # execute :systemctl, '--user', :restart, :slot_subscribe_testnet
          # execute :systemctl, '--user', :restart, :slot_subscribe_pythnet
          execute :systemctl, '--user', :restart, :archive_blockchain_mainnet
          # execute :systemctl, '--user', :restart, :archive_blockchain_testnet
          # execute :systemctl, '--user', :restart, :archive_blockchain_pythnet
        end
      end
    end
  end
end

namespace :rake_task do
  desc 'Add Stake Pools'
  task :add_stake_pools do
    on release_roles([:background]) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'add_stake_pools:mainnet'
        end
      end
    end
  end

  desc 'Update fees in Stake Pools'
  task :update_fees_in_stake_pools do
    on release_roles([:background]) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'update_fees_in_stake_pools:mainnet'
        end
      end
    end
  end
end
