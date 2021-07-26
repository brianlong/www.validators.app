# Based on production
require Rails.root.join('config/environments/production')

Rails.application.routes.default_url_options = {
  host: 'stage.validators.app',
  protocol: 'https' 
}
