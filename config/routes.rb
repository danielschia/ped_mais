Rails.application.routes.draw do

  resources :restaurants do
    resources :products
  end
  resources :orders, only: [:index, :create, :show, :new]
  devise_for :users

  root 'home#index'

  # Swagger UI routes
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  # API routes
  namespace :api do
    namespace :v1 do
      post '/login', to: 'auth#login'
      post '/signup', to: 'auth#signup'

      resources :restaurants, only: [:index, :show, :create, :update, :destroy] do
        resources :products, only: [:index, :show, :create, :update, :destroy]
      end
      resources :orders, only: [:index, :create, :show]
    end
  end
end
