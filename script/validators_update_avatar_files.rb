#frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)

require "digest/md5"
require "open-uri"

NETWORKS.each do |network|
  Validator.where(network: network, is_active: true).where.not(avatar_url: nil).each do |validator|
    begin
      UpdateImageFileService.new(validator, :avatar).call
    rescue OpenURI::HTTPError, OpenSSL::SSL::SSLError, Net::OpenTimeout, SocketError => e
      next
    rescue => e
      Appsignal.send_error(e)
      next
    end
  end
end
