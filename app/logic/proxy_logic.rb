# frozen_string_literal: true

# ProxyLogic provides the get_proxy_host method to select a random proxy
# host and port number to be used for a proxy request.
module ProxyLogic
  ALL_PROXIES = [
    'proxy-001.proxyrain.net',
    'proxy-002.proxyrain.net'
  ].freeze

  # The alt-proxy IP is fixed and the ALT_PROXY_PORTS are randomly selected for
  # different exit nodes. These are the ports:
  ALT_PROXY_PORTS = [].freeze

  # Params:
  #   :use_alt_proxy => Use the alternative residential proxies
  def get_proxy_host(params = {})
    if params[:use_alt_proxy]
      # { host: '', port: ALT_PROXY_PORTS.sample }
      { host: ALL_PROXIES.sample, port: 83 }
    else
      { host: ALL_PROXIES.sample, port: 80 }
    end
  end
end
