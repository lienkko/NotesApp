class Note < ApplicationRecord
  belongs_to :user
  has_many :note_tags, dependent: :destroy
  has_many :tags, through: :note_tags
  belongs_to :category, optional: true

  validates :title, presence: true, length: { maximum: 255 }
  validates :body, presence: true

  def tag_names
    @tag_names || tags.pluck(:name).join(", ")
  end

  def tag_names=(value)
    @tag_names = value
  end

  def assign_tag_names
    names = tag_names.to_s
                  .split(",")
                  .map { |name| name.strip.downcase }
                  .reject(&:blank?)
                  .uniq
    self.tags = names.map do |name|
      Tag.find_or_create_by(name: name)
    end
  end
end
