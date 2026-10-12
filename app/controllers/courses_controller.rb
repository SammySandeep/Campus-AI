class CoursesController < ApplicationController
  def index
    @courses = course_scope.includes(:department, faculty_profile: :user)
  end

  def show
    @course = course_scope.includes(:assignments, :class_sessions).find(params[:id])
  end

  private

  def course_scope
    return current_user.student_profile.courses if current_user.student?
    return current_user.faculty_profile.courses if current_user.faculty?
    Course.all
  end
end
