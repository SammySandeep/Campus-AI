class FacultyProfile < ApplicationRecord
  belongs_to :user
  belongs_to :department
  has_many :courses, dependent: :nullify
  has_many :class_sessions, dependent: :restrict_with_error
  has_many :assignments, dependent: :restrict_with_error
  has_many :mentored_projects, class_name: "Project", dependent: :nullify
  has_many :project_reviews, dependent: :restrict_with_error

  validates :employee_id, presence: true, uniqueness: true
  validates :designation, presence: true
end
