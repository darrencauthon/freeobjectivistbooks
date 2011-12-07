FreeBooks::Application.routes.draw do
  root to: "home#index"
  match "about" => "home#about"
end
