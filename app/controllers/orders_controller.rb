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
    ActiveRecord::Base.transaction do
      items = params[:items] || []
      @order = current_user.orders.new(status: 'pending')
      @order.save!
      products = Product.where(id: items.map { |i| i[:product_id] }).index_by(&:id)
      items.each do |item|
        product = products[item[:product_id]]

        next unless product
        @order.order_items.create!(
          product: products,
          quantity: item[:quantity],
          price: product.price
        )
      end
      ProcessOrderJob.perform_async(@order.id)
    end
    redirect_to @order, notice: "Pedido criado com sucesso."
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error(e.message)
      @order ||= current_user.orders.new
      @order.errors.add(:base, "Erro ao criar pedido: #{e.message}")
      render :new, status: :unprocessable_entity
  end

  private

  def order_params
    params.require(:order).permit()
  end
end
