class Complaint < ApplicationRecord
  belongs_to :reported_by, class_name: "User"
  belongs_to :assigned_to, class_name: "User", optional: true
  has_many :complaint_comments, dependent: :destroy
  validates :title, :description, presence: true
  validates :category, inclusion: { in: %w[IT classroom hostel electrical infrastructure other] }
  validates :priority, inclusion: { in: %w[low medium high urgent] }
  validates :status, inclusion: { in: %w[open assigned in_progress resolved closed] }
  scope :active, -> { where.not(status: %w[resolved closed]) }
end
