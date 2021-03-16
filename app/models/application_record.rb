# frozen_string_literal: true

# ApplicationRecord is an abstract class
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
