FreeBooks::Application.routes.draw do
  root to: "home#index"
  get "about" => "home#about"
  get "signup/read"
  get "signup/donate"
end
