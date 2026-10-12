class ClassSession < ApplicationRecord
  STATUSES = %w[scheduled open closed cancelled].freeze
  belongs_to :course
  belongs_to :faculty_profile
  has_many :attendances, dependent: :destroy

  before_validation :ensure_attendance_token, on: :create
  validates :session_date, :starts_at, :ends_at, presence: true
  validates :attendance_token, presence: true, uniqueness: true
  validates :status, inclusion: { in: STATUSES }
  validate :ends_after_start

  scope :today, -> { where(session_date: Date.current) }

  def attendance_open?
    status == "open" && attendance_expires_at.present? && attendance_expires_at.future?
  end

  def present_count = attendances.where(status: "present").count
  def enrolled_count = course.enrollments.active.count

  private

  def ensure_attendance_token
    self.attendance_token ||= SecureRandom.urlsafe_base64(24)
  end

  def ends_after_start
    errors.add(:ends_at, "must be after the start time") if starts_at && ends_at && ends_at <= starts_at
  end
end
