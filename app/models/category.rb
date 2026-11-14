class Category < ApplicationRecord
  has_many :notes, dependent: :nullify
  validates :name, presence: true, uniqueness: true
end
