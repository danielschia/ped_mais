class AuthController < ApplicationController
  def signup
    user = User.new(user_params)
    render json: user
  end

  def login
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      render json: { message: 'Login successful', user: user }
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end

  private
  def user_params
    params.permit(:email, :password)
  end
end
