# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)
require 'net/http'
require 'uri'
require 'logger'

logger = Logger.new('log/verify_security_report.log')

Validator.where.not(security_report_url: [nil, '']).find_each do |validator|
  url = validator.security_report_url
  begin
    uri = URI.parse(url)
    response = Net::HTTP.get_response(uri)
    puts response.code.to_i
    if response.code.to_i == 404
      logger.info("REMOVED: #{validator.account} | #{url}")
      validator.update(security_report_url: nil)
    else
      logger.info("OK for #{validator.account} (#{url})")
    end
  rescue SocketError, Errno::ECONNREFUSED, URI::InvalidURIError => e
    logger.info("REMOVED (unreachable): #{validator.account} | #{url} | #{e.class} #{e.message}")
    validator.update(security_report_url: nil)
  rescue StandardError => e
    logger.error("UNEXPECTED ERROR for #{validator.account} | #{url} | #{e.class} #{e.message}")
  end
end
