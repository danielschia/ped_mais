class OrdersController < ApplicationController
  def index
    render json: Order.all
  end

  def create
    order = @current_user.orders.new(order_params.merge(status: 'pending'))
    if order.save
      ProcessOrderJob.perform_async(order.id)
      render json: order, status: :created
    else
      render json: { errors: order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def order_params
    params.permit(:user_id, :total)
  end
end
