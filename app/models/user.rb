class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :workspaces, dependent: :destroy
  has_many :notes, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  normalizes :username, with: ->(value) { value.strip.downcase }
  validates :email_address, presence: true, uniqueness: true
  validates :username, presence: true, uniqueness: true,
    length: { in: 3..30 },
    format: { with: /\A[a-z0-9_]+\z/ }
end
