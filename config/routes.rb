Rails.application.routes.draw do
  post '/login', to: 'auth#login'
  post '/signup', to: 'auth#signup'
  resources :orders, only: [:index, :create]
end
