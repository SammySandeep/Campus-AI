class Event < ApplicationRecord
  belongs_to :organizer, class_name: "User"
  has_many :event_registrations, dependent: :destroy
  has_many :student_profiles, through: :event_registrations
  validates :title, :location, :starts_at, :ends_at, :registration_deadline, presence: true
  validates :capacity, numericality: { only_integer: true, greater_than: 0 }
  validates :status, inclusion: { in: %w[draft published cancelled completed] }
  validate :ends_after_start
  scope :published, -> { where(status: "published") }
  scope :upcoming, -> { published.where(starts_at: Time.current..).order(:starts_at) }

  def available_seats = [capacity - event_registrations.where(status: "registered").count, 0].max

  private

  def ends_after_start
    errors.add(:ends_at, "must be after the start time") if starts_at && ends_at && ends_at <= starts_at
  end
end
