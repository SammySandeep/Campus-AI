class Attendance < ApplicationRecord
  belongs_to :class_session
  belongs_to :student_profile
  validates :status, inclusion: { in: %w[present absent excused] }
  validates :student_profile_id, uniqueness: { scope: :class_session_id }
  validates :marked_at, presence: true
end
