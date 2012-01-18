FreeBooks::Application.routes.draw do
  # User-facing

  root to: "home#index"
  get "home" => "home#home"
  get "profile" => "home#profile"
  get "about" => "home#about"

  get "login" => "sessions#new"
  post "login" => "sessions#create"
  match "logout" => "sessions#destroy"

  resource :password, only: [:edit, :update], path_names: {edit: "reset"} do
    member do
      get "forgot"
      post "request_reset"
    end
  end

  get "donate" => "requests#index"
  resources :requests, only: [:show, :edit, :update] do
    member do
      post "grant"
      get "flag"
      post "flag" => "requests#update_flag"
    end
  end

  get "signup/read"
  get "signup/donate"
  post "signup/submit"

  # Admin
  get "admin" => "admin#index"
  namespace :admin do
    resources :users, only: :destroy
  end

  # For testing exceptions
  get "barf" => "home#barf"

  # Catchall to send unknown routes to 404
  match "*path" => "errors#not_found"
end
