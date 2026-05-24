class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_customer!
  before_action :set_restaurant, only: %i[new create]

  def index
    if current_user.owner?
      @orders = Order.joins(order_items: :product)
                     .where(products: {
                     restaurant_id: current_user.restaurants.ids
                                      })
                     .distinct
    else
      @orders = current_user.orders.order(created_at: :desc)
    end
  end

  def show
     @order =
    if current_user.owner?
      Order.joins(order_items: :product)
           .where(products: {
             restaurant_id: current_user.restaurants.ids
           })
           .distinct
           .find(params[:id])
    else
      current_user.orders.find(params[:id])
    end
  end

  def new
    @order = current_user.orders.new
  end

  def create
    ActiveRecord::Base.transaction do
      items = (params[:items] || []).select do |item|
        item[:quantity].to_i.positive?
      end

      @order = current_user.orders.new(status: 'pending')
      @order.save!

      products = Product.where(
        id: items.map { |i| i[:product_id] }
      ).index_by(&:id)

      items.each do |item|
        product = products[item[:product_id].to_i]

        @order.order_items.create!(
          product: product,
          quantity: item[:quantity],
          price: product.price
        )
      end

      ProcessOrderJob.perform_async(@order.id)
    end

    redirect_to @order, notice: "Pedido criado com sucesso."  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error(e.message)

    @order ||= current_user.orders.new
    @order.errors.add(:base, "Erro ao criar pedido: #{e.message}")

    render :new, status: :unprocessable_entity
  end

  private

  def set_restaurant
    @restaurant = Restaurant.includes(:products).find(params[:restaurant_id])
  end
end
