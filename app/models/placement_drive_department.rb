class PlacementDriveDepartment < ApplicationRecord
  belongs_to :placement_drive
  belongs_to :department
  validates :department_id, uniqueness: { scope: :placement_drive_id }
end
