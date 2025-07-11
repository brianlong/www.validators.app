# frozen_string_literal: true

# 'www.validators.app',
# Role explanation:
# app - role used by any task that runs on app server
# web - enables front end on the server, compiles assets; used by capistrano-passenger to restart rails server
# db - runs migrations; define only for one server
# cron - updates crontab. Specific jobs can be assigned to any server (www1, www2 or background - see schedule.rb file).
#        This role is designed to update the crontab only. In the future, think about dropping it and using app role instead.
# background - used for actions that are meant to run only on background server,
#              such as daemons and sidekiq workers. Use for background server only.
# background_production - used for actions/scripts that we only want to run on production background server.
# sidekiq_blockchain - used for managing second sidekiq instance (see sidekiq_blockchain.yml)

# Web server www1
server(
  '104.131.169.171',
  user: 'deploy',
  roles: %w[web app db www1 cron sidekiq_blockchain]
)

# Second web server www2
server(
  '167.172.17.244',
  user: 'deploy',
  roles: %w[web app www2 cron sidekiq_blockchain]
)

# Background server
server(
  '167.99.125.221',
  user: 'deploy',
  roles: %w[app background background_production cron sidekiq_blockchain]
)

# server-based syntax
# ======================
# Defines a single server with a list of roles and multiple properties.
# You can define all roles on a single server, or split them:

# server "example.com", user: "deploy", roles: %w{app db web}, my_property: :my_value
# server "example.com", user: "deploy", roles: %w{app web}, other_property: :other_value
# server "db.example.com", user: "deploy", roles: %w{db}

# role-based syntax
# ==================

# Defines a role with one or multiple servers. The primary server in each
# group is considered to be the first unless any hosts have the primary
# property set. Specify the username and a domain or IP for the server.
# Don't use `:all`, it's a meta role.

# role :app, %w{deploy@example.com}, my_property: :my_value
# role :web, %w{user1@primary.com user2@additional.com}, other_property: :other_value
# role :db,  %w{deploy@example.com}

# Configuration
# =============
# You can set any configuration variable like in config/deploy.rb
# These variables are then only loaded and set in this stage.
# For available Capistrano configuration variables see the documentation page.
# http://capistranorb.com/documentation/getting-started/configuration/
# Feel free to add new variables to customise your setup.

# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult the Net::SSH documentation.
# http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start
#
# Global options
# --------------
#  set :ssh_options, {
#    keys: %w(/home/rlisowski/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
#
# The server-based syntax can be used to override options:
# ------------------------------------
# server "example.com",
#   user: "user_name",
#   roles: %w{web app},
#   ssh_options: {
#     user: "user_name", # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: "please use keys"
#   }
