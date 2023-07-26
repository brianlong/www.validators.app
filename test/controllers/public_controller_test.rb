require 'test_helper'

class PublicControllerTest < ActionDispatch::IntegrationTest
  setup do
    @contact_us_params = {
      contact_request: {
        name: 'Test Name',
        email_address: 'test@test.com',
        telephone: '123456789',
        comments: 'Please contact me.'
      }
    }

    @admin_one = create(:user, :admin)
  end

  test "root_url has mainnet network set as default if param is missing" do
    get root_url
    assert @controller.params[:network], "mainnet"
  end

  test "root_url has mainnet network set as default if param is invalid" do
    get root_url(network: "fake_network")
    assert @controller.params[:network], "mainnet"
  end

  test "root_url has custom network set if param is valid" do
    get root_url(network: "testnet")
    assert @controller.params[:network], "testnet"
  end

  test "root_url leads to public#home" do
    get root_url(network: "testnet")

    assert_equal PublicController, @controller.class
    assert_response :success
  end

  test 'should get index' do
    create(:batch, network: 'mainnet')
    get root_url
    assert_response :success
  end

  test 'should get cookie_policy' do
    get cookie_policy_url
    assert_response :success
  end

  test 'should get faq' do
    get faq_url
    assert_response :success
  end

  test 'should get privacy_policy' do
    get privacy_policy_url
    assert_response :success
  end

  test 'should get terms_of_use' do
    get terms_of_use_url
    assert_response :success
  end

  test 'should get contact_us' do
    get contact_us_url
    assert_response :success
  end

  test 'should redirect from old commission changes URL format' do
    validator = create(:validator, :with_score, network: 'testnet')
    get "/commission-changes/#{validator.network}/#{validator.id}"
    assert_redirected_to commission_histories_path(validator_id: validator.id, network: validator.network)
    get "/commission-changes/testnet"
    assert_redirected_to "/commission-changes/?network=testnet"
  end

  # test 'it creates contact request with correct params' do
  #   assert_difference('ContactRequest.count') do
  #     post contact_us_url, params: @contact_us_params
  #   end
  #   assert_response :success
  # end
  #
  # test 'do not create contact request with name longer than 20 characters' do
  #   @contact_us_params[:contact_request][:name] = \
  #     Faker::Internet.username(specifier: 21)
  #
  #   assert_no_difference('ContactRequest.count') do
  #     post contact_us_url, params: @contact_us_params
  #     assert_response :success
  #   end
  # end
  #
  # test 'it does not create contact request with empty email' do
  #   @contact_us_params[:contact_request][:email_address] = ''
  #   assert_no_difference('ContactRequest.count') do
  #     post contact_us_url, params: @contact_us_params
  #     assert_response :success
  #   end
  # end
  #
  # test 'do not create contact request with email longer than 50 characters' do
  #   @contact_us_params[:contact_request][:email_address] = \
  #     Faker::Internet.email(
  #       name: Faker::Internet.username(specifier: 50),
  #       separators: '_'
  #     )
  #   assert_no_difference('ContactRequest.count') do
  #     post contact_us_url, params: @contact_us_params
  #     assert_response :success
  #   end
  # end
  #
  # test 'it does not create contact request with email in wrong format' do
  #   @contact_us_params[:contact_request][:email_address] = \
  #     'wrong_email_format.com'
  #   assert_no_difference('ContactRequest.count') do
  #     post contact_us_url, params: @contact_us_params
  #     assert_response :success
  #   end
  # end
  #
  # test 'do not create contact request with comments longer than 500 chars' do
  #   @contact_us_params[:contact_request][:comments] = \
  #     Faker::Lorem.characters(number: 501)
  #   assert_no_difference('ContactRequest.count') do
  #     post contact_us_url, params: @contact_us_params
  #     assert_response :success
  #   end
  # end
  #
  # test 'should send email to admins' do
  #   assert_difference('ActionMailer::Base.deliveries.count') do
  #     post contact_us_url, params: @contact_us_params
  #   end
  # end
end
