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

  # ActiveStorage SVG are served as binary files by default
  config.active_storage.content_types_to_serve_as_binary -= ['image/svg+xml']

  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?
end
