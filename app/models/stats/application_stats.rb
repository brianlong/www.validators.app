module Stats
  class ApplicationStats
    #self.abstract_class = true

    attr_reader :network, :batch_uuid, :relation

    def initialize(network, batch_uuid)
      @network = network
      @batch_uuid = batch_uuid
      @relation = ApplicationRecord.none
    end
  end
end
