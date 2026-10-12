class StudentProfile < ApplicationRecord
  belongs_to :user
  belongs_to :department
  has_many :enrollments, dependent: :destroy
  has_many :courses, through: :enrollments
  has_many :attendances, dependent: :destroy
  has_many :submissions, dependent: :destroy
  has_many :project_memberships, dependent: :destroy
  has_many :projects, through: :project_memberships
  has_many :placement_applications, dependent: :destroy
  has_many :event_registrations, dependent: :destroy

  validates :roll_number, presence: true, uniqueness: true
  validates :semester, inclusion: { in: 1..12 }
  validates :graduation_year, numericality: { only_integer: true }
  validates :cgpa, numericality: { in: 0..10 }
  validates :active_backlogs, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def attendance_percentage
    total = attendances.count
    total.zero? ? 0 : (attendances.where(status: "present").count * 100.0 / total).round(1)
  end
end
