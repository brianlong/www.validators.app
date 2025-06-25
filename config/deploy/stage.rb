# frozen_string_literal: true

set :rails_env, :stage

append :linked_files, 'config/credentials/stage.key'

server(
  '64.225.7.18',
  user: 'deploy',
  roles: %w{web app db background www1 sidekiq_blockchain cron}
)
