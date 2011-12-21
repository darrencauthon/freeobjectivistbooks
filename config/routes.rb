FreeBooks::Application.routes.draw do
  root to: "home#index"
  get "about" => "home#about"

  get "signup/read"
  get "signup/donate"
  post "signup/submit"

  # For testing exceptions
  get "barf" => "home#barf"

  # Catchall to send unknown routes to 404
  match "*path" => "errors#not_found"
end
