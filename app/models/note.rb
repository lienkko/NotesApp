class Note < ApplicationRecord
  belongs_to :user
  has_many :note_tags, dependent: :destroy
  has_many :tags, through: :note_tags
  belongs_to :category, optional: true

  validates :title, presence: true, length: { maximum: 255 }
  validates :body, presence: true
end
