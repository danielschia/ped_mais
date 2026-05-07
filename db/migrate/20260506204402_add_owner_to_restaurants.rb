class AddOwnerToRestaurants < ActiveRecord::Migration[7.0]
  def change
    add_reference :restaurants, :owner, null: false, foreign_key: {to_table: :users }
  end
end
