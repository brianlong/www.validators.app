# Based on production
require Rails.root.join('config/environments/production')

Rails.application.routes.default_url_options = {
  host: 'stage.validators.app',
  protocol: 'https'
}

Rails.application.configure do
  config.action_mailer.default_url_options = { host: 'stage.validators.app' }

  config.action_cable.url = 'wss://stage.validators.app/cable'
  config.active_storage.service = :digitalocean

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?
end
