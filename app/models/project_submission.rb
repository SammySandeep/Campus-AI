class ProjectSubmission < ApplicationRecord
  belongs_to :project
  belongs_to :project_milestone, optional: true
  has_one_attached :file
  validates :submitted_at, presence: true
end
