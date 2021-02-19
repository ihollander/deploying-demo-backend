class User < ApplicationRecord
  has_secure_password
  # authenticate!
  validates :username, presence: true
  validates :username, uniqueness: true

end
