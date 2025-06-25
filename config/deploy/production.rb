# frozen_string_literal: true

append :linked_files, 'config/credentials/production.key'

# 'www.validators.app',
# Role explanation:
# app - role used by any task that runs on app server
# web - enables front end on the server, compiles assets; used by capistrano-passenger to eg. restart server
# db - runs migrations
# cron - updates crontab. Specific jobs can be assigned to both servers (see schedule.rb file).
#        This role is designed to update the crontab only.
# background - used for actions that are meant to run on background server,
#              such as daemons and workers. Use for 167.99.125.221 server only.
# background_production - used for actions/scripts that we only want to run on production background server.
# sidekiq_blockchain - used for managing second sidekiq instance (see sidekiq_blockchain.yml)

# Web server www1
server(
  '104.131.169.171',
  user: 'deploy',
  roles: %w[web app db cron sidekiq_blockchain]
)

# Second web server www2
server(
  '167.172.17.244',
  user: 'deploy',
  roles: %w[web app cron sidekiq_blockchain]
)

# Background server
server(
  '167.99.125.221',
  user: 'deploy',
  roles: %w[app background background_production cron sidekiq_blockchain]
)
