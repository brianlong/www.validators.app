# frozen_string_literal: true

module Blockchain
  class JsonRpcRequest
    def initialize(urls)
      @urls = Array(urls)
    end

    def call(method, params = [])
      body = { jsonrpc: "2.0", id: 1, method: method, params: params }.to_json

      @urls.each do |url|
        response = SolanaRpcRuby::ApiClient.new(url).call_api(body: body, http_method: :post)
        result = JSON.parse(response.body)["result"]
        return result unless result.nil?
      rescue SolanaRpcRuby::ApiError, JSON::ParserError => e
        Rails.logger.error("#{method} failed on #{URI(url).host}: #{e.message}")
      end

      nil
    end
  end
end
