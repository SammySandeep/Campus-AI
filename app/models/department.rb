class Department < ApplicationRecord
  has_many :student_profiles, dependent: :restrict_with_error
  has_many :faculty_profiles, dependent: :restrict_with_error
  has_many :courses, dependent: :restrict_with_error
  has_many :placement_drive_departments, dependent: :destroy
  has_many :placement_drives, through: :placement_drive_departments

  validates :name, :code, presence: true
  validates :code, uniqueness: { case_sensitive: false }
end
