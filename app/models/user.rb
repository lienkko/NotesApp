class User < ApplicationRecord
  enum :role, { user: "user", admin: "admin" }, default: :user

  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :workspaces, dependent: :destroy
  has_many :workspace_memberships, dependent: :destroy
  has_many :shared_workspaces, through: :workspace_memberships, source: :workspace
  has_many :notes, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  normalizes :username, with: ->(value) { value.strip.downcase }
  validates :email_address, presence: true, uniqueness: true
  validates :username, presence: true, uniqueness: true,
    length: { in: 3..30 },
    format: { with: /\A[a-z0-9_]+\z/ }
  validates :role, inclusion: { in: roles.keys }

  def self.authenticate_by_identifier(identifier, password)
    normalized_identifier = identifier.to_s.strip.downcase
    user = find_by(email_address: normalized_identifier) ||
      find_by(username: normalized_identifier)

    user&.authenticate(password)
  end

  def accessible_workspaces
    Workspace.where(
      "workspaces.user_id = :user_id OR EXISTS (
        SELECT 1 FROM workspace_memberships
        WHERE workspace_memberships.workspace_id = workspaces.id
        AND workspace_memberships.user_id = :user_id
      )",
      user_id: id
    )
  end
end
