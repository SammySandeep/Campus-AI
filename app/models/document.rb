class Document < ApplicationRecord
  belongs_to :uploaded_by, class_name: "User"
  has_one_attached :file
  validates :title, :category, presence: true
  validates :visibility, inclusion: { in: %w[students faculty admins everyone] }

  scope :visible_to, ->(user) do
    values = ["everyone"]
    values << "students" if user.student?
    values << "faculty" if user.faculty?
    values << "admins" if user.admin?
    where(visibility: values)
  end
end
