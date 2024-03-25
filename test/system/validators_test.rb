# frozen_string_literal: true

require "application_system_test_case"

class ValidatorsTest < ApplicationSystemTestCase
  setup do
    @validator = validators(:one)
  end

  test "visiting the index" do
    visit validators_url
    assert_selector "h1", text: "Validators"
  end

  test "creating a Validator" do
    visit validators_url
    click_on "New Validator"

    fill_in "Account identity", with: @validator.account_identity
    fill_in "Account vote", with: @validator.account_vote
    fill_in "Network", with: @validator.network
    click_on "Create Validator"

    assert_text "Validator was successfully created"
    click_on "Back"
  end

  test "updating a Validator" do
    visit validators_url
    click_on "Edit", match: :first

    fill_in "Account identity", with: @validator.account_identity
    fill_in "Account vote", with: @validator.account_vote
    fill_in "Network", with: @validator.network
    click_on "Update Validator"

    assert_text "Validator was successfully updated"
    click_on "Back"
  end

  test "destroying a Validator" do
    visit validators_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Validator was successfully destroyed"
  end
end
