class ComplaintComment < ApplicationRecord
  belongs_to :complaint
  belongs_to :user
  validates :body, presence: true
end
