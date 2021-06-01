class ApplicationQuery
  include PipelineLogic

  def initialize(network, batch_uuid)
    @network = network
    @batch_uuid = batch_uuid
  end
end
