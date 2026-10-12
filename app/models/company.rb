class Company < ApplicationRecord
  has_many :placement_drives, dependent: :destroy
  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
