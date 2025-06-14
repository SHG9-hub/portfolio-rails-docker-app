Rails.application.routes.draw do
  # ヘルスチェック用エンドポイント（ALB用、SSL制約なし）
  get '/health', to: 'health#check', constraints: { protocol: /https?/ }
  
  devise_for :users
  resources :attendances

  authenticated :user do
    root 'attendances#index', as: :authenticated_root
  end

  devise_scope :user do
    root to: "devise/sessions#new"
  end
end
