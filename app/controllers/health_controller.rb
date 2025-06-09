class HealthController < ApplicationController
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
