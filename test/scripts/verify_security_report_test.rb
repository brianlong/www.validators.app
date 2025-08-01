# frozen_string_literal: true

require 'test_helper'
require 'webmock/minitest'

class VerifySecurityReportScriptTest < ActiveSupport::TestCase
  def setup
    @logger = Logger.new('/dev/null') # wycisz logi w testach
    Validator.delete_all
  end

  test 'clears security_report_url when 404' do
    # This test checks that the script clears the security_report_url if the HTTP response is 404.
    validator = Validator.create!(account: 'test404', security_report_url: 'http://example.com/404')
    stub_request(:get, 'http://example.com/404').to_return(status: 404)

    load Rails.root.join('script/verify_security_report.rb')
    assert_nil validator.reload.security_report_url
  end

  test 'does not clear security_report_url when 200' do
    # This test checks that the script does not clear the security_report_url if the HTTP response is 200.
    validator = Validator.create!(account: 'test200', security_report_url: 'http://example.com/ok')
    stub_request(:get, 'http://example.com/ok').to_return(status: 200)

    load Rails.root.join('script/verify_security_report.rb')
    assert_equal 'http://example.com/ok', validator.reload.security_report_url
  end

  test 'clears security_report_url when url is unreachable' do
    # This test checks that the script clears the security_report_url if the URL is unreachable (network error).
    validator = Validator.create!(account: 'testerr', security_report_url: 'http://badurl')
    stub_request(:get, 'http://badurl').to_raise(SocketError)

    load Rails.root.join('script/verify_security_report.rb')
    assert_nil validator.reload.security_report_url
  end
end
