class Api::V1::ProductsController < Api::V1::BaseController
  before_action :set_restaurant

  def index
    render json: @restaurant.products
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:restaurant_id])
  end
end
