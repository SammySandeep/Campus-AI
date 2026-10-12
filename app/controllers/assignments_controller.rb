class AssignmentsController < ApplicationController
  before_action :require_faculty!, only: %i[new create edit update]

  def index
    @assignments = assignment_scope.includes(:course).order(due_at: :asc)
  end

  def show
    @assignment = assignment_scope.includes(submissions: { student_profile: :user }).find(params[:id])
    @submission = current_user.student? ? @assignment.submissions.find_or_initialize_by(student_profile: current_user.student_profile) : nil
  end

  def new
    @assignment = Assignment.new
  end

  def create
    faculty = current_user.faculty? ? current_user.faculty_profile : Course.find(assignment_params[:course_id]).faculty_profile
    @assignment = faculty.assignments.new(assignment_params)
    if @assignment.save
      @assignment.course.student_profiles.includes(:user).find_each do |student|
        NotificationCreator.call(user: student.user, title: "New assignment", body: @assignment.title, type: "assignment", notifiable: @assignment)
      end
      Activity.create!(user: current_user, action: "assignment_created", description: "#{@assignment.title} was created for #{@assignment.course.code}.", trackable: @assignment)
      redirect_to @assignment, notice: "Assignment created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @assignment = manageable_assignments.find(params[:id])
  end

  def update
    @assignment = manageable_assignments.find(params[:id])
    if @assignment.update(assignment_params)
      redirect_to @assignment, notice: "Assignment updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def assignment_scope
    return Assignment.published.joins(course: :enrollments).where(enrollments: { student_profile_id: current_user.student_profile.id }).distinct if current_user.student?
    return current_user.faculty_profile.assignments if current_user.faculty?
    Assignment.all
  end

  def manageable_assignments
    current_user.faculty? ? current_user.faculty_profile.assignments : Assignment.all
  end

  def assignment_params
    params.require(:assignment).permit(:course_id, :title, :description, :due_at, :maximum_marks, :published)
  end
end
