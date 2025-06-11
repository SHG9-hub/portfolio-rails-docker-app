Rails.application.routes.draw do
  # ヘルスチェック用エンドポイント（ALB用、SSL制約なし）
  get '/health', to: 'health#check', constraints: { protocol: /https?/ }
  
  devise_for :users
  resources :attendances

  # ログイン済みのユーザーは勤怠一覧ページへ
  authenticated :user do
    root 'attendances#index', as: :authenticated_root
  end

  # 未ログインのユーザーはログインページへ
  # Deviseのコントローラーを直接指定する代わりにリダイレクトを使用
  root to: redirect('/users/sign_in')
end
