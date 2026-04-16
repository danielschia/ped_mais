class OrdersController < ApplicationController
  before_action :authenticate_user!

  def index
    @orders = current_user.orders.order(created_at: :desc)
  end

  def show
    @order = current_user.orders.find(params[:id])
  end

  def new
    @order = current_user.orders.new
  end

  def create
    @order = current_user.orders.new(order_params.merge(status: 'pending'))

    if @order.save
      ProcessOrderJob.perform_async(@order.id)
      redirect_to @order, notice: 'Pedido criado com sucesso!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def order_params
    params.require(:order).permit(:total)
  end
end
