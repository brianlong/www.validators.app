# frozen_string_literal: true

class Blockchain::BlockFooter < ApplicationRecord
  self.abstract_class = true

  NETWORK_CLASSES = {
    "alpenglow-community" => "Blockchain::AlpenglowCommunityBlockFooter"
  }.freeze

  connects_to database: { writing: :blockchain, reading: :blockchain }

  enum finalization: { fast: 0, slow: 1 }

  class << self
    def network(network)
      class_name = NETWORK_CLASSES[network]
      raise ArgumentError, "Block footers are not supported for #{network}" unless class_name

      class_name.constantize
    end
  end
end
