Rails.application.routes.draw do
  devise_for :users
  resources :attendances, only: [:index, :new, :create, :edit, :update]
  root to: "attendances#index"
  get "up" => "rails/health#show", as: :rails_health_check
end
