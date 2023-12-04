# Based on production
require Rails.root.join('config/environments/production')

Rails.application.routes.default_url_options = {
  host: 'stage.validators.app',
  protocol: 'https' 
}

Rails.application.configure do
  config.action_mailer.default_url_options = { host: 'stage.validators.app' }

  config.action_cable.url = 'wss://stage.validators.app/cable'
  config.active_storage.service = :amazon
end
