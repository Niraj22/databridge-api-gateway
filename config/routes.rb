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
      resources :customers, only: [:index, :show, :create, :update, :destroy]
      
      # Order service routes
      resources :orders, only: [:index, :show, :create, :update, :destroy]
      
      # Product service routes
      resources :products, only: [:index, :show, :create, :update, :destroy]
      
      # Analytics service routes
      get 'analytics/dashboard', to: 'analytics#dashboard'
      get 'analytics/reports', to: 'analytics#reports'
    end
  end
  
  # Add a root route for health checks
  root to: proc { [200, {}, ['DataBridge API Gateway']] }
end
