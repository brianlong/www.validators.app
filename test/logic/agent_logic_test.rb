# frozen_string_literal: true

require 'test_helper'

class AgentLogicTest < ActiveSupport::TestCase
  include AgentLogic

  test 'get_page 200' do
    VCR.use_cassette('agent_logic/get_page_200', record: :new_episodes) do
      result = get_page(url: 'https://www.movingleads.com/')
      assert_equal '200', result[:http_code]
      assert_equal true,  !result[:html].blank?
      assert_equal true,  result[:html].include?('Moving Leads')
      assert_equal 1,     result[:tries]
    end # VCR
  end # test

  test 'get_page 404' do
    VCR.use_cassette('agent_logic/get_page_404', record: :new_episodes) do
      result = get_page(url: 'https://www.movingleads.com/toss?code=404')
      assert_equal '404', result[:http_code]
      assert_equal 1, result[:tries]
      assert_equal '404 => Net::HTTPNotFound for https://www.movingleads.com/toss?code=404 -- unhandled response',
                   result[:errors][0]
    end # VCR
  end

  test 'get_page 403' do
    VCR.use_cassette('agent_logic/get_page_403', record: :new_episodes) do
      result = get_page(url: 'https://www.movingleads.com/toss?code=403')
      assert_equal '403', result[:http_code]
      assert_equal 3, result[:tries]
      assert_equal '403 => Net::HTTPForbidden for https://www.movingleads.com/toss?code=403 -- unhandled response',
                   result[:errors][0]
    end # VCR
  end

  test 'redirect to ssl' do
    VCR.use_cassette('agent_logic/redirect_to_ssl', record: :new_episodes) do
      result = get_page(url: 'http://www.movingleads.com')
      assert_equal '200', result[:http_code]
      assert_equal 1,     result[:tries]
      assert_nil result[:errors][0]
    end # VCR
  end # test

  # private
  #
  # def use_cassette(name)
  #   VCR.use_cassette("agent_logic/#{name}") do
  #     yield
  #   end
  # end
end # class
