require "test_helper"

class PlacementEligibilityCheckerTest < ActiveSupport::TestCase
  setup do
    _user, @student = student(cgpa: 8.0, backlogs: 0, graduation_year: 2027)
    company = Company.create!(name: "Demo Corp #{SecureRandom.hex(2)}")
    @drive = PlacementDrive.create!(company: company, title: "Graduate Drive", minimum_cgpa: 7.5, maximum_backlogs: 0, graduation_year: 2027, registration_deadline: 2.days.from_now, drive_date: 1.week.from_now, status: "open")
    PlacementDriveDepartment.create!(placement_drive: @drive, department: department)
  end

  test "returns structured reasons for an eligible student" do
    result = PlacementEligibilityChecker.new(@student, @drive).call
    assert result.eligible
    assert_equal 5, result.reasons.size
    assert result.reasons.all? { |reason| reason[:passed] }
  end

  test "explains failed requirements" do
    @student.update!(cgpa: 6.0, active_backlogs: 2)
    result = PlacementEligibilityChecker.new(@student, @drive).call
    assert_not result.eligible
    assert_equal 2, result.reasons.count { |reason| !reason[:passed] }
  end
end
