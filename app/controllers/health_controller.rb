class HealthController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!
  before_action :disable_ssl_redirect
  
  def check
    ActiveRecord::Base.connection.execute('SELECT 1')

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
    request.env['HTTP_X_FORWARDED_PROTO'] = 'http' if Rails.env.production?
  end
end
