class HealthController < ApplicationController
  # ALBヘルスチェック用にSSL強制を無効化
  skip_before_action :verify_authenticity_token
  before_action :disable_ssl_redirect
  
  def check
    # データベース接続チェック
    ActiveRecord::Base.connection.execute('SELECT 1')

    # HTTPヘッダーを明示的に設定
    response.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = '0'

    render json: {
      status: 'ok',
      timestamp: Time.current,
      version: Rails.version,
      environment: Rails.env,
      protocol: request.protocol
    }, status: :ok
  rescue => e
    render json: {
      status: 'error',
      error: e.message,
      timestamp: Time.current
    }, status: :service_unavailable
  end

  private

  def disable_ssl_redirect
    # SSL強制リダイレクトを明示的に無効化
    request.env['HTTP_X_FORWARDED_PROTO'] = 'http' if Rails.env.production?
  end
end
