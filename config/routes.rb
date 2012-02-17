FreeBooks::Application.routes.draw do
  # User-facing

  root to: "home#index"
  get "home" => "home#home"
  get "about" => "home#about"

  get "profile" => "profile#show"

  get "donate" => "requests#index"
  resources :requests, only: [:show, :edit, :update] do
    member do
      put "flag"
      put "thank"
    end
    resource :donation, only: [:create]
  end

  resources :donations, only: [:index, :destroy] do
    get "cancel", on: :member
    resource :status, only: [:edit, :update]
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

  # Test
  match "test/noop"
  match "test/exception"
  get "test/buttons"

  # Catchall to send unknown routes to 404
  match "*path" => "errors#not_found"
end
