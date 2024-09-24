# frozen_string_literal: true
require "rails_helper"

RSpec.feature "Identity auth", type: :system do
  include CommonSteps
  include QualificationAuthenticationSteps

  scenario "User signs out", test: %i[with_stubbed_auth with_fake_quals_api] do
    given_the_qualifications_service_is_open
    and_identity_auth_is_mocked
    and_i_am_signed_in_via_identity
    when_i_click_the_sign_out_link
    and_confirm_my_sign_out
    then_i_am_on_service_sign_in_page
  end

  private

  def then_i_am_on_the_start_page
    expect(page).to have_current_path(qualifications_sign_in_path)
  end

  def when_i_click_the_sign_out_link
    click_link "Sign out"
  end

  def and_confirm_my_sign_out
    click_button "Confirm"
  end

  def then_i_am_on_service_sign_in_page
    expect(page).to have_current_path qualifications_sign_in_path
  end

  def when_i_click_the_button_to_take_me_back_to_the_service
   click_link "Back to GOV.UK"
  end

  def then_i_am_on_service_start_page
    expect(page).to have_current_path qualifications_start_path
  end
end

