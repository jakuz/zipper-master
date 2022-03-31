class User < ApplicationRecord
  has_secure_password

  has_many :attachments
  validates :email, presence: true, uniqueness: true,
    format: { with: /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/ }
end
