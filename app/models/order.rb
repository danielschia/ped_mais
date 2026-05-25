class Order < ApplicationRecord
  belongs_to :user
  belongs_to :restaurant

  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  enum status: {
    pending: 'pending',
    preparing: 'preparing',
    delivered: 'delivered',
    canceled: 'canceled'
  }

  validates :total, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true

  def calculate_total
    self.total = order_items.sum do |item|
      item.quantity * item.price
    end
  end
end
