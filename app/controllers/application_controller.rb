class ApplicationController < ActionController::Base
  # ログアウト後のリダイレクト先を設定
  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path  # ログインページにリダイレクト
  end

  # ログイン後のリダイレクト先を設定
  def after_sign_in_path_for(resource)
    attendances_path  # ダッシュボードにリダイレクト
  end
end
