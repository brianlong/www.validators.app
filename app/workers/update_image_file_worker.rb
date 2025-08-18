# frozen_string_literal: true

class UpdateImageFileWorker
  include Sidekiq::Worker
  sidekiq_options retry: 1, dead: false

  def perform(args = {})
    validator = Validator.find(args["validator_id"])
    begin
      UpdateImageFileService.new(validator, :avatar).call
    rescue OpenURI::HTTPError, OpenSSL::SSL::SSLError, Net::OpenTimeout, SocketError => e
      Rails.logger.error("Network error while updating image for validator #{validator.account}: #{e.message}")
    end
  end
end
