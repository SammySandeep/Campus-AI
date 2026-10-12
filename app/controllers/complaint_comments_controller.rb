class ComplaintCommentsController < ApplicationController
  def create
    complaint = current_user.admin? ? Complaint.find(params[:complaint_id]) : Complaint.where(reported_by: current_user).find(params[:complaint_id])
    comment = complaint.complaint_comments.new(comment_params.merge(user: current_user))
    if comment.save
      redirect_to complaint, notice: "Comment added."
    else
      redirect_to complaint, alert: comment.errors.full_messages.to_sentence
    end
  end

  private

  def comment_params = params.require(:complaint_comment).permit(:body)
end
