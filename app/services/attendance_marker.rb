class AttendanceMarker
  Result = Data.define(:success, :attendance, :error)

  def initialize(student_profile:, class_session:, token:)
    @student = student_profile
    @session = class_session
    @token = token
  end

  def call
    return failure("Invalid attendance link") unless ActiveSupport::SecurityUtils.secure_compare(@session.attendance_token, @token.to_s)
    return failure("Attendance is not currently open") unless @session.attendance_open?
    return failure("You are not enrolled in this course") unless @session.course.enrollments.active.exists?(student_profile: @student)
    return failure("Attendance has already been marked") if @session.attendances.exists?(student_profile: @student)

    attendance = @session.attendances.create(student_profile: @student, status: "present", marked_at: Time.current)
    attendance.persisted? ? Result.new(true, attendance, nil) : failure(attendance.errors.full_messages.to_sentence)
  end

  private

  def failure(message) = Result.new(false, nil, message)
end
