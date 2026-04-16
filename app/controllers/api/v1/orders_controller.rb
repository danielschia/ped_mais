module Api
  module V1
    class OrdersController < Api::V1::BaseController
      before_action :authenticate_user!
      before_action :set_order, only: %i[show]

      def index
        orders = current_user.orders.order(created_at: :desc)
        render json: orders, status: :ok
      end

      def show
        render json: @order, status: :ok
      end

      def create
        order = current_user.orders.new(order_params.merge(status: 'pending'))

        if order.save
          ProcessOrderJob.perform_async(order.id)
          render json: order, status: :created
        else
          render json: { errors: order.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_order
        @order = current_user.orders.find(params[:id])
      end

      def order_params
        params.require(:order).permit(:total)
      end
    end
  end
end
