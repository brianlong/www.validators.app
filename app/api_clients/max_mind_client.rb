# frozen_string_literal: true

class MaxMindClient
  def initialize
    @client = maxmind_client
  end

  def insights(ip)
    @client.insights(ip)
  end

  private

  def maxmind_client
    @client ||= MaxMind::GeoIP2::Client.new(
      account_id: Rails.application.credentials.max_mind[:account_id],
      license_key: Rails.application.credentials.max_mind[:license_key]
    )
  end
end
