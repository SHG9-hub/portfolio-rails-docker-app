Rails.application.routes.draw do
  devise_for :users
  resources :attendances
  root to: "attendances#index"
  get "up" => "rails/health#show", as: :rails_health_check
end
