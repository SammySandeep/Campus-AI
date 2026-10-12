class AttendancesController < ApplicationController
  before_action :require_student!

  def show
    @class_session = ClassSession.includes(:course).find_by!(attendance_token: params[:token])
    @already_marked = @class_session.attendances.exists?(student_profile: current_user.student_profile)
  end

  def create
    class_session = ClassSession.find_by!(attendance_token: params[:token])
    result = AttendanceMarker.new(student_profile: current_user.student_profile, class_session: class_session, token: params[:token]).call
    if result.success
      Activity.create!(user: current_user, action: "attendance_marked", description: "Attendance marked for #{class_session.course.code}.", trackable: result.attendance)
      redirect_to attendance_path(params[:token]), notice: "Attendance marked successfully."
    else
      redirect_to attendance_path(params[:token]), alert: result.error
    end
  end
end
