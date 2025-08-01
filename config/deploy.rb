# frozen_string_literal: true

# config valid for current version and patch releases of Capistrano
lock '~> 3.17.3'

set :application, 'validators.app'

set :repo_url, 'git@github.com:brianlong/www.validators.app.git'

set :user, 'deploy'

# Default branch is :master
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

set :migration_role, :db

set :templated_config_files, []

set :sitemap_roles, :web

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push(
  'config/database.yml', 'config/appsignal.yml', 'config/cluster.yml', 'config/sidekiq.yml', '.env', 'mise.toml'
)

# Default value for linked_dirs is []
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system'

#set :passenger_environment_variables, { path: '/usr/sbin/passenger-status:$PATH' }

set :passenger_roles, :web

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

# Whenever/crontab config. Updates crontab on all servers with this role.
# Selects cron tasks by roles defined in config/schedule.rb
set :whenever_roles, ["cron"]

# Use Procfile and supervisor on all servers with the app role.
set :procfile_role, :app

namespace :sidekiq do
  desc 'Quiet sidekiq'
  task :quiet do
    # Sidekiq will stop fetching new jobs, see: https://github.com/mperham/sidekiq/wiki/Signals#tstp
    on roles :sidekiq do
      invoke!('opscomplete:supervisor:signal_procs', 'TSTP', 'sidekiq')
    end
    on roles :sidekiq_blockchain do
      invoke!('opscomplete:supervisor:signal_procs', 'TSTP', 'sidekiq_blockchain')
    end
  end

  desc 'Stop sidekiq'
  task :stop do
    # Sidekiq will terminate and push back to Redis any jobs that don't finish within the configure timeout.
    on roles :sidekiq do
      execute :supervisor_stop_procs, "sidekiq"
    end
    on roles :sidekiq_blockchain do
      execute :supervisor_stop_procs, "sidekiq_blockchain"
    end
  end

  desc 'Restart sidekiq'
  task :restart do
    on roles(:sidekiq), in: :sequence, wait: 5 do
      execute :supervisor_restart_procs, "sidekiq"
    end
    on roles(:sidekiq_blockchain), in: :sequence, wait: 5 do
      execute :supervisor_restart_procs, "sidekiq_blockchain"
    end
  end
end

namespace :daemons do
  desc 'Stop background daemons'
  task :stop do
    on roles :background do
      execute :supervisor_stop_procs
    end
  end

  desc 'Restart background daemons'
  task :restart do
    on roles :background do
      execute :supervisor_restart_procs
    end
  end
end

namespace :solana do
  desc 'Install solana-cli'
  task :install do
    on roles(:app), in: :sequence do
      within release_path do
        execute :mise, "install"
      end
    end
  end

  task :trust do
    on roles(:app), in: :sequence do
      within release_path do
        execute :mise, "trust"
      end
    end
  end

  task :list_available_versions do
    on roles(:app), in: :sequence do
      within release_path do
        execute :mise, "ls-remote", "ubi:anza-xyz/agave"
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

namespace :deploy do
  after :starting, 'sidekiq:quiet' # quiets Sidekiq

  after :updating, 'opscomplete:ruby:ensure' # installs Ruby version specified in .ruby-version
  after :updating, 'opscomplete:nodejs:ensure' # installs nodejs specified in .nvmrc

  after :restart, 'rake_task:add_stake_pools'
  after :restart, 'sitemap:create'

  # TODO uncomment after testing
  # restart sidekiq and daemons
  # after 'deploy:published', 'opscomplete:supervisor:restart_procs'
end