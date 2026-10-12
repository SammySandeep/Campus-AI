class Activity < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :trackable, polymorphic: true, optional: true
  validates :action, :description, presence: true
  scope :recent, -> { order(created_at: :desc) }
end
