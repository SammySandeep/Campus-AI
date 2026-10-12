module Api
  module V1
    class CoursesController < BaseController
      def index
        scope = current_user.student? ? current_user.student_profile.courses : (current_user.faculty? ? current_user.faculty_profile.courses : Course.all)
        render json: scope.as_json(only: %i[id code name semester credits])
      end
    end
  end
end
