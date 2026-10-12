class Project < ApplicationRecord
  belongs_to :faculty_profile, optional: true
  has_many :project_memberships, dependent: :destroy
  has_many :student_profiles, through: :project_memberships
  has_many :project_milestones, dependent: :destroy
  has_many :project_submissions, dependent: :destroy
  has_many :project_reviews, dependent: :destroy
  validates :title, :academic_year, presence: true
  validates :status, inclusion: { in: %w[proposed approved in_progress submitted completed rejected] }
end
