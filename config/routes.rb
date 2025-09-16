Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # API routes
  namespace :api do
    namespace :v1 do
      resources :clients do
        resources :appointments, except: [:index]
      end
      
      resources :appointments, only: [:index, :show, :update, :destroy]
      
    end
  end

  # Root route
  root 'api/v1/clients#index'
end
