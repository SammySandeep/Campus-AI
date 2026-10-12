class PlacementApplication < ApplicationRecord
  belongs_to :placement_drive
  belongs_to :student_profile
  validates :student_profile_id, uniqueness: { scope: :placement_drive_id }
  validates :status, inclusion: { in: %w[applied shortlisted interview selected rejected withdrawn] }
  validates :applied_at, presence: true
end
