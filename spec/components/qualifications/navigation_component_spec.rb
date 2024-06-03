# frozen_string_literal: true

require "rails_helper"

RSpec.describe Qualifications::NavigationComponent, type: :component do
  context "current_user is nil" do
    it "renders a nav for a signed out user" do
      render_inline(described_class.new(current_user: nil))
      expect(page).not_to have_content "Sign out"
    end
  end

  context "given a current_user" do
    let(:user) { instance_double(User) }

    it "renders a Sign Out link" do
      render_inline(described_class.new(current_user: user))
      expect(page).to have_link("Sign out", href: path_helpers.qualifications_new_sign_out_path)
    end

    context "if one_login feature active" do
      before { FeatureFlags::FeatureFlag.activate(:one_login) }

      it "renders a link to the One Login account page" do
        render_inline(described_class.new(current_user: user))
        expect(page).to have_link("Account", href: path_helpers.qualifications_one_login_user_path)
      end
    end

    context "if one_login feature flag is not active" do
      it "renders a link to the Identity account page" do
        render_inline(described_class.new(current_user: user))
        expect(page).to have_link("Account", href: path_helpers.qualifications_identity_user_path)
        expect(page).not_to have_link("Account", href: path_helpers.qualifications_one_login_user_path)
      end
    end
  end

  private

  def path_helpers
    Rails.application.routes.url_helpers
  end
end
