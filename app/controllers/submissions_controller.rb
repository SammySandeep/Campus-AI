class SubmissionsController < ApplicationController
  before_action :require_student!

  def create
    assignment = student_assignment
    submission = assignment.submissions.new(submission_params.merge(student_profile: current_user.student_profile, submitted_at: Time.current, status: Time.current > assignment.due_at ? "late" : "submitted"))
    if submission.save
      redirect_to assignment, notice: "Work submitted successfully."
    else
      redirect_to assignment, alert: submission.errors.full_messages.to_sentence
    end
  end

  def update
    assignment = student_assignment
    submission = assignment.submissions.find_by!(student_profile: current_user.student_profile)
    if assignment.due_at.past?
      redirect_to assignment, alert: "The submission deadline has passed."
    elsif submission.update(submission_params.merge(submitted_at: Time.current))
      redirect_to assignment, notice: "Submission updated."
    else
      redirect_to assignment, alert: submission.errors.full_messages.to_sentence
    end
  end

  private

  def student_assignment
    Assignment.published.joins(course: :enrollments).where(enrollments: { student_profile_id: current_user.student_profile.id }).find(params[:assignment_id])
  end

  def submission_params = params.require(:submission).permit(:work_file)
end
