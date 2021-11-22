class ApplicationQuery
  include PipelineLogic

  def initialize(network, batch_uuid)
    @network = network
    @batch_uuid = batch_uuid
  end

  def call
    # Existing child classes need to be changed to uncomment that.
    # raise NotImplementedError, 'call method must implement query logic'
  end
end
