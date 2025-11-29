require "sidekiq/web"

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Return Requests - API and UI
  resources :return_requests, only: [:index, :show, :new, :create]

  # Integrations - Vehicle Models
  get '/integrations/vehicle_models', to: 'integrations#vehicle_models'
  get '/integrations/discontinued_models', to: 'integrations#discontinued_models'

  # Rules
  resources :rules, only: [:index]

  mount Sidekiq::Web => "/sidekiq"

  # Root path
  root 'return_requests#index'
end
