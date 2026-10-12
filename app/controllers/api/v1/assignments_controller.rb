module Api
  module V1
    class AssignmentsController < BaseController
      def index
        scope = Assignment.published
        scope = scope.joins(course: :enrollments).where(enrollments: { student_profile_id: current_user.student_profile.id }) if current_user.student?
        scope = scope.where(faculty_profile: current_user.faculty_profile) if current_user.faculty?
        render json: scope.as_json(only: %i[id course_id title due_at maximum_marks published])
      end
    end
  end
end
