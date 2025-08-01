# frozen_string_literal: true

set :rails_env, :production

set :deploy_to, "/var/www/validators_p"

append :linked_files, 'config/credentials/production.key'

# 'www.validators.app',
# Role explanation:
# app - role used by any task that runs on app server
# web - enables front end on the server, compiles assets; used by capistrano-passenger to restart rails server
# db - runs migrations; define only for one server
# cron - updates crontab. Specific jobs can be assigned to any server (www1, www2 or background - see schedule.rb file).
#        This role is designed to update the crontab only. In the future, think about dropping it and using app role instead.
# background - used for actions that are meant to run only on background server,
#              such as daemons. Use for background server only.
# background_production - used for actions/scripts that we only want to run on production background server.
# sidekiq, sidekiq_blockchain - used for managing sidekiq instances

# Web server www1
server(
  'app01-prod.blocklogic.validators.app',
  user: 'deploy-validators_p',
  roles: %w[web app db www1 cron sidekiq_blockchain]
)

# Second web server www2
server(
  'app02-prod.blocklogic.validators.app',
  user: 'deploy-validators_p',
  roles: %w[web app www2 cron sidekiq_blockchain]
)

# Background server
server(
  'background01-prod.blocklogic.validators.app',
  user: 'deploy-validators_p',
  roles: %w[app background background_production cron sidekiq sidekiq_blockchain]
)
