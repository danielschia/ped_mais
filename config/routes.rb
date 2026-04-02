Rails.application.routes.draw do
  # Swagger UI routes
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  # Your existing routes
  post '/login', to: 'auth#login'
  post '/signup', to: 'auth#signup'
  resources :orders, only: [:index, :create]
end
