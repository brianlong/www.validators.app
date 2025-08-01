# frozen_string_literal: true

set :rails_env, :stage

set :deploy_to, "/var/www/validators_p"

append :linked_files, 'config/credentials/stage.key'

server(
  'app01-stage.blocklogic.validators.app',
  user: 'deploy-validators_s',
  roles: %w{web app db background www1 sidekiq sidekiq_blockchain cron}
)
