class Workspace < ApplicationRecord
  belongs_to :user
  has_many :notes, dependent: :destroy
  has_many :workspace_memberships, dependent: :destroy
  has_many :members, through: :workspace_memberships, source: :user

  validates :name, presence: true, uniqueness: { scope: :user_id }
end
