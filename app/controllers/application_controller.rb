class ApplicationController < ActionController::API
  before_action :authorize_request

  def authorize_request
    header = request.headers['Authorization']
    if header.present?
      token = header.split(' ').last

      begin
        decoded = JwtService.decode(token)
        @current_user = User.find(decoded[:user_id])
      rescue
        render json: { error: 'Unauthorized' }, status: :unauthorized
      end
    else
      render json: { error: 'Missing token' }, status: :unauthorized
    end
  end
end
