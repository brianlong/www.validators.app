# frozen_string_literal: true

require 'test_helper'

class OptOutRequestTest < ActiveSupport::TestCase
  setup do
    @opt_out_request = build :opt_out_request
  end

  test 'opt-out request without type is not created' do
    @opt_out_request.request_type = ''
    refute @opt_out_request.valid?
    assert_no_difference('OptOutRequest.count') do
      @opt_out_request.save
    end
  end

  test 'opt-out request without name is not created' do
    @opt_out_request.name = ''
    refute @opt_out_request.valid?
    assert_no_difference('OptOutRequest.count') do
      @opt_out_request.save
    end
  end

  test 'opt-out request with too long name is not created' do
    @opt_out_request.name = Faker::Internet.username(specifier: 41)
    assert_no_difference('OptOutRequest.count') do
      @opt_out_request.save
    end
  end

  test 'opt-out request without address fields is not created' do
    @opt_out_request.street_address = ''
    refute @opt_out_request.valid?
    assert_no_difference('OptOutRequest.count') do
      @opt_out_request.save
    end

    @opt_out_request.street_address = '2575 Pearl St, Ste 230'
    @opt_out_request.city = ''
    refute @opt_out_request.valid?
    assert_no_difference('OptOutRequest.count') do
      @opt_out_request.save
    end

    @opt_out_request.city = 'Boulder'
    @opt_out_request.postal_code = ''
    refute @opt_out_request.valid?
    assert_no_difference('OptOutRequest.count') do
      @opt_out_request.save
    end
  end

  test 'opt-out request with empty or incorrect state is not created' do
    @opt_out_request.state = ''
    refute @opt_out_request.valid?
    assert_no_difference('OptOutRequest.count') do
      @opt_out_request.save
    end

    @opt_out_request.state = ''
    refute @opt_out_request.valid?
    assert_no_difference('OptOutRequest.count') do
      @opt_out_request.save
    end
  end

  test 'opt-out request with correct params is created' do
    assert @opt_out_request.valid?
    assert_difference('OptOutRequest.count') do
      @opt_out_request.save
    end
    assert_equal 'opt_out', @opt_out_request.request_type
    assert_equal '127.0.0.1', @opt_out_request.meta_data['ip']
  end

  test 'opt-out request has name and address encrypted' do
    opt_out_request = create(
      :opt_out_request,
      name: 'John Doe',
      street_address: '2575 Pearl St, Ste 230',
      city: 'Boulder',
      postal_code: '80302',
      state: 'CO'
    )
    opt_out_request.reload

    assert_equal 'John Doe', opt_out_request.name
    assert_equal '2575 Pearl St, Ste 230', opt_out_request.street_address
    assert_equal 'Boulder', opt_out_request.city
    assert_equal '80302', opt_out_request.postal_code
    assert_equal 'CO', opt_out_request.state
    refute_equal 'John Doe', opt_out_request.name_encrypted
    refute_equal '2575 Pearl St, Ste 230', opt_out_request.street_address_encrypted
    refute_equal 'Boulder', opt_out_request.city_encrypted
    refute_equal '80302', opt_out_request.postal_code_encrypted
    refute_equal 'CO', opt_out_request.state_encrypted
  end
end
