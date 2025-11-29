require "sidekiq/web"

Rails.application.routes.draw do
  mount Sidekiq::Web => "/sidekiq"

  get "up" => "rails/health#show", as: :rails_health_check

  # Return Requests API and UI
  resources :return_requests, only: [:index, :show, :new, :create]

  # IntegrationsVehicle Models
  get '/integrations/vehicle_models', to: 'integrations#vehicle_models'
  get '/integrations/discontinued_models', to: 'integrations#discontinued_models'

  # Rules
  resources :rules, only: [:index]

  # Root path
  root 'return_requests#index'
end
