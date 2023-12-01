#frozen_string_literal: true

require "digest/md5"
require "open-uri"

NETWORKS.each do |network|
  Validator.where(network: network, is_active: true).where.not(avatar_url: nil).each do |validator|
    begin
      UpdateAvatarFileService.new(validator).call
    rescue
      puts "Error updating avatar for #{validator.account} on #{validator.network}"
      next
    end
  end
end
