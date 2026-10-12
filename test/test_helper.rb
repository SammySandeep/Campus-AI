ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: 1)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

module CampusTestData
  def department
    @department ||= Department.create!(name: "Computer Science", code: "CSE#{SecureRandom.hex(2)}")
  end

  def student(email: "student-#{SecureRandom.hex(3)}@example.com", cgpa: 8.2, backlogs: 0, graduation_year: 2027)
    user = User.create!(email: email, password: "password123", first_name: "Test", last_name: "Student", role: :student)
    profile = StudentProfile.create!(user: user, department: department, roll_number: "R#{SecureRandom.hex(4)}", semester: 6, graduation_year: graduation_year, cgpa: cgpa, active_backlogs: backlogs)
    [user, profile]
  end

  def faculty
    user = User.create!(email: "faculty-#{SecureRandom.hex(3)}@example.com", password: "password123", first_name: "Test", last_name: "Faculty", role: :faculty)
    profile = FacultyProfile.create!(user: user, department: department, employee_id: "E#{SecureRandom.hex(4)}", designation: "Professor")
    [user, profile]
  end

  def course(faculty_profile = faculty.last)
    Course.create!(name: "AI Systems", code: "C#{SecureRandom.hex(3)}", semester: 6, credits: 4, department: department, faculty_profile: faculty_profile)
  end
end

ActiveSupport::TestCase.include CampusTestData
