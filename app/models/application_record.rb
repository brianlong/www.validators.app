class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  if Rails.env.production?
    connects_to database: { writing: :primary,  staging: :staging }
  end
end
