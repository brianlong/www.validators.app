# frozen_string_literal: true

require 'test_helper'

class ProxyLogicTest < ActiveSupport::TestCase
  include ProxyLogic

  test 'get_proxy_host returns proxyRAIN by default' do
    assert get_proxy_host[:host].include?('rain')
    assert get_proxy_host[:port] == 80
  end

  test 'get_proxy_host returns special proxy when requested' do
    special_proxy = get_proxy_host(use_alt_proxy: true)
    assert special_proxy[:host].include?('rain')
  end
end
