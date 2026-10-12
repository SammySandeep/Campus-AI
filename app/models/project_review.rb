class ProjectReview < ApplicationRecord
  belongs_to :project
  belongs_to :faculty_profile
  validates :comments, :reviewed_at, presence: true
  validates :score, numericality: { only_integer: true, in: 0..100 }, allow_nil: true
end
