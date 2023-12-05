#frozen_string_literal: true

require "digest/md5"
require "open-uri"

NETWORKS.each do |network|
  Validator.where(network: network, is_active: true).where.not(avatar_url: nil).each do |validator|
    begin
      UpdateAvatarFileService.new(validator).call
    rescue => e
      Appsignal.send_error(e)
      next
    end
  end
end
