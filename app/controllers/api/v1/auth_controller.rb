module Api
  module V1
    class AuthController < Api::V1::BaseController
      skip_before_action :authenticate_user!, only: [:signup, :login]

      def signup
        user = User.new(user_params)

        if user.save
          render json: user, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def login
        user = User.find_by(email: params[:email])

        if user&.valid_password?(params[:password])
          token = JwtService.encode(user_id: user.id)

          render json: { token: token }
        else
          render json: { error: 'Invalid credentials' }, status: :unauthorized
        end
      end

      private

      def user_params
        params.permit(:email, :password)
      end
    end
  end
end
