class HealthController < ApplicationController
  # ALBヘルスチェック用にSSLを無効化（将来的にSSLリダイレクトが追加された場合の準備）
  # skip_before_action :force_ssl_redirect, only: [:check], if: :ssl_configured?

  def check
    # データベース接続チェック
    ActiveRecord::Base.connection.execute('SELECT 1')

    render json: {
      status: 'ok',
      timestamp: Time.current,
      version: Rails.version
    }, status: :ok
  rescue => e
    render json: {
      status: 'error',
      error: e.message,
      timestamp: Time.current
    }, status: :service_unavailable
  end

  private

  def ssl_configured?
    Rails.application.config.force_ssl
  end
end
