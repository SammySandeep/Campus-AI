class ProjectsController < ApplicationController
  def index
    @projects = project_scope.includes(:faculty_profile, :student_profiles)
  end

  def show
    @project = project_scope.includes(:project_milestones, :project_reviews, student_profiles: :user).find(params[:id])
  end

  private

  def project_scope
    current_user.student? ? current_user.student_profile.projects : Project.all
  end
end
