server(
  '64.225.7.18',
  user: 'deploy',
  roles: %w{web app db background www1 sidekiq_blockchain cron}
)
