class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  enum role: { customer: 0, restaurant: 1 }
  has_many :orders

  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }
end
