module SolPrices
  class ApiClient
    def initialize(api_url:)
      @api_url = URI(api_url)
    end

    # FTX
    def send_request(request)
      Net::HTTP.start(
        @api_url.hostname,
        @api_url.port,
        use_ssl: @api_url.scheme == 'https'
      ) { |http| http.request(request) }
    end
  end
end
