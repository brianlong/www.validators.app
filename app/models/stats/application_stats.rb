# frozen_string_literal: true

# Stats module extracts stats from models
module Stats
  class ApplicationStats
    attr_reader :network, :batch_uuid, :relation

    def initialize(network, batch_uuid)
      @network = network
      @batch_uuid = batch_uuid
      @relation = ApplicationRecord.none
    end
  end
end
