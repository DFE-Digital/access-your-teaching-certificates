Rails.application.routes.draw do
  root to: "pages#home"

  devise_for :staff,
             controllers: {
               confirmations: "staff/confirmations",
               invitations: "staff/invitations",
               passwords: "staff/passwords",
               sessions: "staff/sessions",
               unlocks: "staff/unlocks"
             }

  namespace :support_interface, path: "/support" do
    get "/", to: "support_interface#index"

    mount FeatureFlags::Engine => "/features"
  end

  devise_for :users,
             controllers: {
               omniauth_callbacks: "users/omniauth_callbacks"
             }
  get "/sign-in", to: "users/sign_in#new"
  get "/accessibility", to: "static#accessibility"
  get "/cookies", to: "static#cookies"
  get "/privacy", to: "static#privacy"
end
