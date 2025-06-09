Rails.application.routes.draw do
  # ヘルスチェック用エンドポイント（ALB用、SSL制約なし）
  get '/health', to: 'health#check', constraints: { protocol: /https?/ }
  
  devise_for :users
  resources :attendances
  root to: "attendances#index"
end
