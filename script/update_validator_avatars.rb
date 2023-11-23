#frozen_string_literal: true

require "digest/md5"
require "open-uri"

TMP_STORAGE_PATH = Rails.root.join("storage", "validators", "avatars", "tmp").to_s.freeze

NETWORKS.each do |network|
  # next unless network == 'mainnet'

  Validator.where(network: network).where.not(avatar_url: nil).each do |validator|
    begin
      UpdateAvatarFileService.new(validator).call
    rescue
      puts "Error updating avatar for #{validator.account} on #{validator.network}"
      next
    end
  end
end
