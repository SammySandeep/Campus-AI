class ProjectMilestone < ApplicationRecord
  belongs_to :project
  has_many :project_submissions, dependent: :nullify
  validates :title, :due_at, presence: true
  validates :status, inclusion: { in: %w[pending in_progress submitted completed] }
end
