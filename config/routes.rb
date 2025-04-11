# config/routes.rb
Rails.application.routes.draw do
  # Mount Swagger documentation
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  
  namespace :api do
    namespace :v1 do
      # Auth routes
      post 'auth/login', to: 'auth#login'
      post 'auth/register', to: 'auth#register'
      post 'auth/refresh', to: 'auth#refresh'
      
      # Customer service routes
      resources :customers, only: [:index, :show, :create, :update, :destroy] do
        # Nested routes for addresses and preferences
        resources :addresses, only: [:index, :show, :create, :update, :destroy]
        resources :preferences, only: [:index, :show, :update, :destroy]
      end
      
      # Order service routes
      resources :orders, only: [:index, :show, :create, :update, :destroy]
      
      # Products and categories
      resources :products
      resources :categories
      
      # Inventory routes
      get 'products/:product_id/inventory', to: 'inventories#show'
      put 'products/:product_id/inventory', to: 'inventories#update'
      post 'inventories/batch', to: 'inventories#batch_update'
      

      resources :orders do
        resources :payments, only: [:index, :create]
        resources :shipments, only: [:index, :create, :update]
      end
      
      # Analytics service routes
      get 'analytics/dashboard', to: 'analytics#dashboard'
      get 'analytics/reports', to: 'analytics#reports'
    end
  end
  
  # Add a root route for health checks
  root to: proc { [200, {}, ['DataBridge API Gateway']] }
end