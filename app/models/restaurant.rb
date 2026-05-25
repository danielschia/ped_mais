class Restaurant < ApplicationRecord
  belongs_to :owner, class_name: 'User'
  has_many :products, dependent: :destroy
  has_many :orders, dependent: :destroy

  validates :name, presence: true
end
