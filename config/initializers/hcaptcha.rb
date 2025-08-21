Hcaptcha.configure do |config|
  config.site_key = Rails.application.credentials.dig(:hcaptcha, :site_key)
  config.secret_key = Rails.application.credentials.dig(:hcaptcha, :secret_key)
end
