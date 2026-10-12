class Assignment < ApplicationRecord
  belongs_to :course
  belongs_to :faculty_profile
  has_many :submissions, dependent: :destroy
  validates :title, :due_at, presence: true
  validates :maximum_marks, numericality: { only_integer: true, greater_than: 0 }
  scope :published, -> { where(published: true) }
  scope :upcoming, -> { where(due_at: Time.current..).order(:due_at) }
end
