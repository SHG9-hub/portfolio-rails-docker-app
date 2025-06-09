Rails.application.routes.draw do
  # ヘルスチェック用エンドポイント（ALB用、SSL制約なし）
  get '/health', to: 'health#check', constraints: { protocol: /https?/ }
  
  devise_for :users
  resources :attendances

  # ALBヘルスチェック対応: 本番環境のみrootをヘルスチェックに
  if Rails.env.production?
    root 'health#check'
  else
    root to: redirect('/users/sign_in')
  end
end
