class Submission < ApplicationRecord
  belongs_to :assignment
  belongs_to :student_profile
  has_one_attached :work_file
  validates :student_profile_id, uniqueness: { scope: :assignment_id }
  validates :status, inclusion: { in: %w[draft submitted graded late] }
  validate :marks_within_range

  private

  def marks_within_range
    return if marks.blank? || assignment.blank?
    errors.add(:marks, "must be between 0 and #{assignment.maximum_marks}") unless marks.between?(0, assignment.maximum_marks)
  end
end
