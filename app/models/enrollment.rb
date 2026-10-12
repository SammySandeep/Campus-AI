class Enrollment < ApplicationRecord
  belongs_to :student_profile
  belongs_to :course
  validates :academic_year, :status, presence: true
  validates :course_id, uniqueness: { scope: [:student_profile_id, :academic_year] }
  scope :active, -> { where(status: "active") }
end
