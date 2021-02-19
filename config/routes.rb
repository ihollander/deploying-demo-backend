Rails.application.routes.draw do
  post "/login", to: "users#login"
  post "/signup", to: "users#signup"
  get "/me", to: "users#show"
  patch "/me", to: "users#update"

  get "/login/spotify", to: "users#spotify_redirect"
  get "/login/spotify/callback", to: "users#spotify_callback"

end
