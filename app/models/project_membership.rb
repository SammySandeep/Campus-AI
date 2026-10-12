class ProjectMembership < ApplicationRecord
  belongs_to :project
  belongs_to :student_profile
  validates :student_profile_id, uniqueness: { scope: :project_id }
  validates :team_role, presence: true
end
