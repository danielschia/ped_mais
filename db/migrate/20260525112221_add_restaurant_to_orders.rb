class AddRestaurantToOrders < ActiveRecord::Migration[7.0]
  def change
    add_reference :orders, :restaurant, null: false, foreign_key: true
  end
end
