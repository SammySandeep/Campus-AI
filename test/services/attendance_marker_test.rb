require "test_helper"

class AttendanceMarkerTest < ActiveSupport::TestCase
  setup do
    _faculty_user, faculty_profile = faculty
    @course = course(faculty_profile)
    _student_user, @student = student
    Enrollment.create!(student_profile: @student, course: @course, academic_year: "2026-27")
    @session = ClassSession.create!(course: @course, faculty_profile: faculty_profile, session_date: Date.current, starts_at: Time.zone.parse("10:00"), ends_at: Time.zone.parse("11:00"), status: "open", attendance_expires_at: 10.minutes.from_now)
  end

  test "marks attendance once for an enrolled student" do
    result = AttendanceMarker.new(student_profile: @student, class_session: @session, token: @session.attendance_token).call
    assert result.success
    assert_equal "present", result.attendance.status

    duplicate = AttendanceMarker.new(student_profile: @student, class_session: @session, token: @session.attendance_token).call
    assert_not duplicate.success
    assert_match(/already/, duplicate.error)
  end

  test "rejects an expired session" do
    @session.update!(attendance_expires_at: 1.minute.ago)
    result = AttendanceMarker.new(student_profile: @student, class_session: @session, token: @session.attendance_token).call
    assert_not result.success
    assert_match(/not currently open/, result.error)
  end
end
