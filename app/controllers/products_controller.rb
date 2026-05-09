class ProductsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_owner!
  before_action :set_restaurant
  before_action :set_product, only: %i[show update destroy]

  def index
    @products = @restaurant.products
  end

  def show; end

  def new
    @product = @restaurant.products.new
  end

  def create
    @product = @restaurant.products.new(product_params)

    if @product.save
      redirect_to [@restaurant, @product], notice: 'Produto criado com sucesso.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @product.update(product_params)
      redirect_to [@restaurant, @product], notice: 'Produto atualizado com sucesso.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    redirect_to restaurant_products_path(@restaurant), notice: 'Produto removido.'
  end

  private

  def set_restaurant
    @restaurant = current_user.restaurants.find(params[:restaurant_id])
  end

  def set_product
    @product = @restaurant.products.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :price)
  end
end
