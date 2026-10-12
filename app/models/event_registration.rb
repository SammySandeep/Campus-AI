class EventRegistration < ApplicationRecord
  belongs_to :event
  belongs_to :student_profile
  validates :student_profile_id, uniqueness: { scope: :event_id }
  validates :status, inclusion: { in: %w[registered cancelled attended] }
  validates :registered_at, presence: true
end
