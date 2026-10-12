class Course < ApplicationRecord
  belongs_to :department
  belongs_to :faculty_profile, optional: true
  has_many :enrollments, dependent: :destroy
  has_many :student_profiles, through: :enrollments
  has_many :class_sessions, dependent: :destroy
  has_many :assignments, dependent: :destroy

  validates :name, :code, presence: true
  validates :code, uniqueness: { case_sensitive: false }
  validates :semester, inclusion: { in: 1..12 }
  validates :credits, numericality: { only_integer: true, greater_than: 0 }
end
