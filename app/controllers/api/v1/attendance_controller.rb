module Api
  module V1
    class AttendanceController < BaseController
      def index
        return render json: { error: "student account required" }, status: :forbidden unless current_user.student?
        render json: current_user.student_profile.attendances.includes(class_session: :course).map { |a| { id: a.id, course: a.class_session.course.code, date: a.class_session.session_date, status: a.status, marked_at: a.marked_at } }
      end
    end
  end
end
