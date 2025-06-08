Rails.application.routes.draw do
  # ヘルスチェック用エンドポイント
  get '/health', to: 'health#check'
  
  devise_for :users
  resources :attendances
  root to: "attendances#index"
end
