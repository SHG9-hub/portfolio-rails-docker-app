class HealthController < ApplicationController
  # ALBヘルスチェック用にSSL強制を無効化
  skip_before_action :verify_authenticity_token
  
  def check
    # データベース接続チェック
    ActiveRecord::Base.connection.execute('SELECT 1')

    render json: {
      status: 'ok',
      timestamp: Time.current,
      version: Rails.version,
      environment: Rails.env
    }, status: :ok
  rescue => e
    render json: {
      status: 'error',
      error: e.message,
      timestamp: Time.current
    }, status: :service_unavailable
  end
end
