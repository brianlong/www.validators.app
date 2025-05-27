class Blockchain::Archive < ApplicationRecord
    self.abstract_class = true

    connects_to database: { writing: :blockchain, reading: :blockchain }
    # connects_to database: { writing: Rails.env.stage? ? nil : :blockchain, reading: :blockchain }
end