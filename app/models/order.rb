class Order < ApplicationRecord
  belongs_to :user
  belongs_to :restaurant
  enum status: {
    pending: 0,
    preparing: 1,
    delivered: 2,
    canceled: 3
  }
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  validates :total, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true

  def total
    order_items.sum("quantity * price")
  end
end
