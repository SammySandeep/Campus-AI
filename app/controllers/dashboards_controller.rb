class DashboardsController < ApplicationController
  def show
    @stats = DashboardStatistics.new(current_user).call
    @activities = Activity.recent.limit(8)
    @upcoming_events = Event.upcoming.limit(4)
    @today_sessions = today_sessions
    @upcoming_assignments = upcoming_assignments
  end

  private

  def today_sessions
    scope = ClassSession.today.includes(:course)
    return scope.joins(course: :enrollments).where(enrollments: { student_profile_id: current_user.student_profile.id }) if current_user.student?
    return scope.where(faculty_profile: current_user.faculty_profile) if current_user.faculty?
    scope.limit(8)
  end

  def upcoming_assignments
    scope = Assignment.published.upcoming.includes(:course)
    return scope.joins(course: :enrollments).where(enrollments: { student_profile_id: current_user.student_profile.id }).limit(5) if current_user.student?
    return scope.where(faculty_profile: current_user.faculty_profile).limit(5) if current_user.faculty?
    scope.limit(5)
  end
end
