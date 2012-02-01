FreeBooks::Application.routes.draw do
  # User-facing

  root to: "home#index"
  get "home" => "home#home"
  get "about" => "home#about"

  get "profile" => "profile#show"
  get "donations" => "profile#donations"

  get "donate" => "requests#index"
  resources :requests, only: [:show, :edit, :update] do
    member do
      put "grant"
      put "flag"
      put "thank"
      put "update_status"
    end
    resources :messages, only: [:new, :create]
  end

  get "login" => "sessions#new"
  post "login" => "sessions#create"
  match "logout" => "sessions#destroy"

  get "signup/read"
  get "signup/donate"
  post "signup/submit"

  resource :password, only: [:edit, :update], path_names: {edit: "reset"} do
    member do
      get "forgot"
      post "request_reset"
    end
  end

  # Admin
  get "admin" => "admin#index"
  namespace :admin do
    resources :users
    resources :requests
    resources :pledges
    resources :events
    resources :campaign_targets, only: [:index, :new, :create, :destroy]
  end

  # For testing exceptions
  get "barf" => "home#barf"

  # Catchall to send unknown routes to 404
  match "*path" => "errors#not_found"
end
