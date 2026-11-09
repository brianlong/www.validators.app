# frozen_string_literal: true

require "uri"
require "net/http"
require "openssl"
require "base64"

class XClient
  API_URL = "https://api.x.com/2/tweets"
  CREDENTIAL_KEYS = %i[api_key api_secret access_token access_token_secret].freeze

  class XResponseError < StandardError; end

  def initialize(credentials: Rails.application.credentials.dig(:x))
    @credentials = credentials || {}
  end

  def configured?
    CREDENTIAL_KEYS.all? { |key| @credentials[key].present? }
  end

  def create_post(text:, in_reply_to: nil)
    body = { text: text }
    body[:reply] = { in_reply_to_tweet_id: in_reply_to } if in_reply_to

    uri = URI(API_URL)
    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = oauth_header("POST", API_URL)
    request["Content-Type"] = "application/json"
    request.body = body.to_json

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(request) }
    raise XResponseError, "#{response.code}: #{response.body}" unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body).dig("data", "id")
  end

  private

  def oauth_header(method, url)
    params = {
      oauth_consumer_key: @credentials[:api_key],
      oauth_nonce: SecureRandom.hex(16),
      oauth_signature_method: "HMAC-SHA1",
      oauth_timestamp: Time.now.to_i.to_s,
      oauth_token: @credentials[:access_token],
      oauth_version: "1.0"
    }
    params[:oauth_signature] = oauth_signature(method, url, params)

    "OAuth " + params.sort.map { |key, value| "#{key}=\"#{escape(value)}\"" }.join(", ")
  end

  def oauth_signature(method, url, params)
    param_string = params.sort.map { |key, value| "#{escape(key)}=#{escape(value)}" }.join("&")
    base_string = [method, escape(url), escape(param_string)].join("&")
    signing_key = "#{escape(@credentials[:api_secret])}&#{escape(@credentials[:access_token_secret])}"

    Base64.strict_encode64(OpenSSL::HMAC.digest("sha1", signing_key, base_string))
  end

  def escape(value)
    ERB::Util.url_encode(value.to_s)
  end
end
