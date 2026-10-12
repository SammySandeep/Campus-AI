class ClassSessionsController < ApplicationController
  before_action :require_faculty!, except: :index

  def index
    @class_sessions = session_scope.includes(:course, :attendances).order(session_date: :desc, starts_at: :desc)
  end

  def show
    @class_session = manageable_sessions.includes(attendances: { student_profile: :user }).find(params[:id])
  end

  def new
    @class_session = ClassSession.new(session_date: Date.current, starts_at: Time.current.change(sec: 0), ends_at: 1.hour.from_now.change(sec: 0))
  end

  def create
    faculty = current_user.faculty? ? current_user.faculty_profile : Course.find(class_session_params[:course_id]).faculty_profile
    @class_session = faculty.class_sessions.new(class_session_params)
    if @class_session.save
      redirect_to @class_session, notice: "Class session created. Open attendance when class begins."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def open_attendance
    class_session = manageable_sessions.find(params[:id])
    class_session.update!(status: "open", attendance_token: SecureRandom.urlsafe_base64(24), attendance_expires_at: 20.minutes.from_now)
    redirect_to class_session, notice: "Attendance is open for 20 minutes."
  end

  def close_attendance
    class_session = manageable_sessions.find(params[:id])
    class_session.update!(status: "closed", attendance_expires_at: Time.current)
    redirect_to class_session, notice: "Attendance closed."
  end

  private

  def session_scope
    return ClassSession.joins(course: :enrollments).where(enrollments: { student_profile_id: current_user.student_profile.id }) if current_user.student?
    manageable_sessions
  end

  def manageable_sessions
    current_user.faculty? ? current_user.faculty_profile.class_sessions : ClassSession.all
  end

  def class_session_params
    params.require(:class_session).permit(:course_id, :session_date, :starts_at, :ends_at, :room, :status)
  end
end
