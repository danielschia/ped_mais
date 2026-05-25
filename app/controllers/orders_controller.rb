class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_customer!, only: %i[new create]
  before_action :set_restaurant, only: %i[new create]
  before_action :require_owner!, only: [:update_status]

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
    @order = current_user.orders.new(
      restaurant: @restaurant,
      status: :pending
    )
  end

  def create
    ActiveRecord::Base.transaction do
      items = (params[:items] || []).select do |item|
        item[:quantity].to_i.positive?
      end

      @order = current_user.orders.new(
        restaurant: @restaurant,
        status: :pending,
        total: 0
      )

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

      @order.calculate_total
      @order.save!

      ProcessOrderJob.perform_async(@order.id)
    end

    redirect_to @order,
                notice: 'Pedido criado com sucesso.'
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error(e.message)

    @order ||= current_user.orders.new(
      restaurant: @restaurant
    )

    @order.errors.add(
      :base,
      "Erro ao criar pedido: #{e.message}"
    )

    render :new, status: :unprocessable_entity
  end

  def preparing
    @order = current_user.orders.find(params[:id])
    @order.start_preparing!
    redirect_to @order,
                notice: 'Pedido em preparação.'
  end

  def confirm_delivery
    @order = current_user.orders.find(params[:id])

    @order.confirm_delivery!

    redirect_to @order,
                notice: 'Entrega confirmada.'
  end

  def cancel
    @order = current_user.orders.find(params[:id])

    @order.cancel!

    redirect_to @order,
                notice: 'Pedido cancelado.'
  end

  private

  def set_restaurant
    @restaurant = Restaurant.includes(:products)
                            .find(params[:restaurant_id])
  end

  def start_preparing!
    update!(status: :preparing)
  end

  def confirm_delivery!
    update!(status: :delivered)
  end

  def cancel!
    update!(status: :canceled)
  end
end
