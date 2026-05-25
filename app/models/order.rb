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
  validate :status_cannot_change_if_finished

  def calculate_total
    self.total = order_items.sum do |item|
      item.quantity * item.price
    end
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

  private

  def status_cannot_change_if_finished
    return unless persisted?
    return unless will_save_change_to_status?

    previous_status = status_change_to_be_saved.first
    return unless previous_status.in?(%w[delivered canceled])

    errors.add(:status, 'não pode ser alterado após o pedido ser entregue ou cancelado.')
  end
end
