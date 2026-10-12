class User < ApplicationRecord
  has_secure_password

  enum :role, { student: 0, faculty: 1, department_admin: 2, super_admin: 3 }

  has_one :student_profile, dependent: :destroy
  has_one :faculty_profile, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :reported_complaints, class_name: "Complaint", foreign_key: :reported_by_id, dependent: :restrict_with_error
  has_many :assigned_complaints, class_name: "Complaint", foreign_key: :assigned_to_id, dependent: :nullify

  normalizes :email, with: ->(email) { email.strip.downcase }
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, :last_name, presence: true

  scope :active, -> { where(active: true) }

  def full_name = "#{first_name} #{last_name}"
  def admin? = department_admin? || super_admin?
  def department
    student_profile&.department || faculty_profile&.department
  end
end
