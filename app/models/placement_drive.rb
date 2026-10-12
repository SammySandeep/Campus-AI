class PlacementDrive < ApplicationRecord
  belongs_to :company
  has_many :placement_drive_departments, dependent: :destroy
  has_many :departments, through: :placement_drive_departments
  has_many :placement_applications, dependent: :destroy
  validates :title, :registration_deadline, :drive_date, :graduation_year, presence: true
  validates :minimum_cgpa, numericality: { in: 0..10 }
  validates :maximum_backlogs, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :status, inclusion: { in: %w[draft open closed completed cancelled] }
  scope :active, -> { where(status: "open").where(registration_deadline: Time.current..) }
end
