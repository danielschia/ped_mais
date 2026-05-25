require 'sidekiq/web'

Rails.application.routes.draw do
  resources :orders, only: [:index, :show] do
    member do
      patch :confirm_delivery
      patch :cancel
    end
  end
  resources :restaurants do
    resources :products
    resources :orders, only: [:index, :create, :show, :new] do
      member do
        patch :confirm_delivery
        patch :cancel
        patch :preparing
      end
    end
  end

  # Admin dashboard for Sidekiq
  mount Sidekiq::Web => '/sidekiq'

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
