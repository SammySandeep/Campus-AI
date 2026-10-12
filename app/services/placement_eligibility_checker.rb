class PlacementEligibilityChecker
  Result = Data.define(:eligible, :reasons)

  def initialize(student_profile, placement_drive)
    @student = student_profile
    @drive = placement_drive
  end

  def call
    checks = {
      "CGPA #{@student.cgpa} meets minimum #{@drive.minimum_cgpa}" => @student.cgpa >= @drive.minimum_cgpa,
      "Active backlogs #{@student.active_backlogs} are within maximum #{@drive.maximum_backlogs}" => @student.active_backlogs <= @drive.maximum_backlogs,
      "Department #{@student.department.code} is allowed" => @drive.department_ids.include?(@student.department_id),
      "Graduation year #{@student.graduation_year} matches" => @student.graduation_year == @drive.graduation_year,
      "Registration is open" => @drive.status == "open" && @drive.registration_deadline.future?
    }
    Result.new(checks.values.all?, checks.map { |message, passed| { message: message, passed: passed } })
  end
end
