FreeBooks::Application.routes.draw do
  # User-facing

  root to: "home#index"
  get "home" => "home#home"
  get "profile" => "home#profile"
  get "about" => "home#about"

  get "login" => "sessions#new"
  post "login" => "sessions#create"
  match "logout" => "sessions#destroy"

  get "donate" => "requests#index"
  resources :requests, only: [] do
    post "grant", on: :member
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
