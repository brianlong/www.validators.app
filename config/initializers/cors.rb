# frozen_string_literal: true

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  Rails.application.credentials.cors_domain_whitelist.each do |domain|
    allow do
      origins domain
      resource '/api/v1/*', headers: :any, methods: %i[get post]
    end
  end
end
