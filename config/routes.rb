FreeBooks::Application.routes.draw do
  # User-facing

  root to: "home#index"
  get "about" => "home#about"

  get "login" => "sessions#new"
  post "login" => "sessions#create"
  match "logout" => "sessions#destroy"

  get "signup/read"
  get "signup/donate"
  post "signup/submit"

  # Admin
  resources :admin, only: :index

  # For testing exceptions
  get "barf" => "home#barf"

  # Catchall to send unknown routes to 404
  match "*path" => "errors#not_found"
end
