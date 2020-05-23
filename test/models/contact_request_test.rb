require 'test_helper'

class ContactRequestTest < ActiveSupport::TestCase
  setup do
    @contact_request = ContactRequest.new(
      name: Faker::Internet.username(specifier: 10),
      email_address: Faker::Internet.email,
      telephone: Faker::PhoneNumber.phone_number,
      comments: Faker::Lorem.sentence
    )
  end

  test 'contact request without name is not created' do
    @contact_request.name = ''
    assert_no_difference('ContactRequest.count') do
      @contact_request.save
    end
  end

  test 'contact request with name longer than 20 characters is not created' do
    @contact_request.name = Faker::Internet.username(specifier: 21)
    assert_no_difference('ContactRequest.count') do
      @contact_request.save
    end
  end

  test 'contact request without email address is not created' do
    @contact_request.email_address = ''
    assert_no_difference('ContactRequest.count') do
      @contact_request.save
    end
  end

  test 'contact request with email longer than 50 characters is not created' do
    too_long_email = Faker::Internet.email(
      name: Faker::Internet.username(specifier: 50),
      separators: '_'
    )
    @contact_request.email_address = too_long_email
    assert_no_difference('ContactRequest.count') do
      @contact_request.save
    end
  end

  test 'contact request with email address in wrong format is not created' do
    @contact_request.email_address = 'wrong_email_format.com'
    assert_no_difference('ContactRequest.count') do
      @contact_request.save
    end
  end

  test 'contact request with too long comments is not created' do
    @contact_request.comments = Faker::Lorem.characters(number: 501)
    assert_no_difference('ContactRequest.count') do
      @contact_request.save
    end
  end

  test 'contact request has name, email and telephone encrypted' do
    contact_request = ContactRequest.create(
      name: 'test',
      email_address: 'test@fma_template.com',
      telephone: '1234567890',
      comments: 'TEST COMMENT'
    )
    contact_request.reload

    assert_equal 'test', contact_request.name
    assert_equal 'test@fma_template.com', contact_request.email_address
    assert_equal '1234567890', contact_request.telephone
    assert_equal 'TEST COMMENT', contact_request.comments
    refute_equal 'test', contact_request.name_encrypted
    refute_equal 'test@fma_template.com',
                 contact_request.email_address_encrypted
    refute_equal '1234567890', contact_request.telephone_encrypted
    refute_equal 'TEST COMMENT', contact_request.comments_encrypted
  end
end
