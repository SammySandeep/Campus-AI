class DashboardStatistics
  def initialize(user) = @user = user

  def call
    case @user.role
    when "student" then student_stats
    when "faculty" then faculty_stats
    when "department_admin" then admin_stats(@user.department)
    else system_stats
    end
  end

  private

  def student_stats
    student = @user.student_profile
    {
      "Attendance" => "#{student.attendance_percentage}%",
      "Assignments due" => Assignment.published.upcoming.joins(course: :enrollments).where(enrollments: { student_profile_id: student.id }).distinct.count,
      "Upcoming events" => Event.upcoming.count,
      "Eligible drives" => PlacementDrive.active.count { |drive| PlacementEligibilityChecker.new(student, drive).call.eligible },
      "Open complaints" => @user.reported_complaints.active.count,
      "Unread notifications" => @user.notifications.unread.count
    }
  end

  def faculty_stats
    faculty = @user.faculty_profile
    {
      "Today's classes" => faculty.class_sessions.today.count,
      "Students" => Enrollment.active.where(course: faculty.courses).distinct.count(:student_profile_id),
      "Awaiting grading" => Submission.where(assignment: faculty.assignments, marks: nil).count,
      "Project reviews" => Project.where(faculty_profile: faculty, status: "submitted").count
    }
  end

  def admin_stats(department)
    {
      "Students" => department.student_profiles.count,
      "Faculty" => department.faculty_profiles.count,
      "Courses" => department.courses.count,
      "Open complaints" => Complaint.active.count,
      "Upcoming events" => Event.upcoming.count,
      "Active drives" => PlacementDrive.active.count
    }
  end

  def system_stats
    {
      "Departments" => Department.count,
      "Users" => User.count,
      "Students" => StudentProfile.count,
      "Faculty" => FacultyProfile.count,
      "Courses" => Course.count,
      "Open complaints" => Complaint.active.count,
      "Upcoming events" => Event.upcoming.count,
      "Active drives" => PlacementDrive.active.count
    }
  end
end
