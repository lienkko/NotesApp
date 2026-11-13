class Note < ApplicationRecord
  belongs_to :user

  validates :title, presence: true, length: { maximum: 255 }
  validates :body, presence: true
  validates :category, length: { maximum: 100 }, allow_blank: true
end
