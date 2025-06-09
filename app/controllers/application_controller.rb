class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  # ログアウト後のリダイレクト先を設定
  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path  # ログインページにリダイレクト
  end

  # ログイン後のリダイレクト先を設定
  def after_sign_in_path_for(resource)
    attendances_path  # ダッシュボードにリダイレクト
  end

  # ALBヘルスチェック用にSSLリダイレクトを制御
  def force_ssl_redirect?
    # /health パスの場合はSSLリダイレクトをスキップ
    return false if request.path == '/health'
    
    # その他のパスでは通常のSSL設定を使用
    Rails.application.config.force_ssl
  end
end
