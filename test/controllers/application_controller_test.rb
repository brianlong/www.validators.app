# frozen_string_literal: true

require 'test_helper'

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  test 'should handle unknown format with JSON request on validators' do
    get '/validators.json'
    assert_response :not_acceptable
    
    json_response = JSON.parse(response.body)
    assert_equal 'Format not supported', json_response['error']
    assert_match(/application\/json/, response.content_type)
  end

  test 'should handle unknown format with XML request on validators' do
    get '/validators.xml'
    assert_response :not_acceptable
    assert_empty response.body
  end

  test 'should handle unknown format with PDF request on validators' do
    get '/validators.pdf'
    assert_response :not_acceptable
    assert_empty response.body
  end

  test 'should handle unknown format on data centers' do
    get '/data-centers.json'
    assert_response :not_acceptable
    
    json_response = JSON.parse(response.body)
    assert_equal 'Format not supported', json_response['error']
  end

  test 'should handle unknown format on map page' do
    get '/map.csv'
    assert_response :not_acceptable
    assert_empty response.body
  end

  test 'should handle unknown format on root page' do
    get root_path(format: :json)
    assert_response :not_acceptable
    
    json_response = JSON.parse(response.body)
    assert_equal 'Format not supported', json_response['error']
  end
end
