class ComplaintsController < ApplicationController
  before_action :require_student!, only: %i[new create]
  before_action :require_admin!, only: :update

  def index
    @complaints = complaint_scope.includes(:reported_by, :assigned_to).order(created_at: :desc)
    @complaints = @complaints.where(status: params[:status]) if params[:status].present?
  end

  def show
    @complaint = complaint_scope.includes(complaint_comments: :user).find(params[:id])
    @comment = ComplaintComment.new
  end

  def new
    @complaint = Complaint.new
  end

  def create
    @complaint = current_user.reported_complaints.new(complaint_params)
    if @complaint.save
      Activity.create!(user: current_user, action: "complaint_created", description: "Helpdesk ticket #{@complaint.title} was opened.", trackable: @complaint)
      redirect_to @complaint, notice: "Complaint submitted. The helpdesk has been notified."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @complaint = complaint_scope.find(params[:id])
  end

  def update
    @complaint = Complaint.find(params[:id])
    previous_status = @complaint.status
    attrs = complaint_params
    attrs[:resolved_at] = Time.current if attrs[:status].in?(%w[resolved closed])
    if @complaint.update(attrs)
      if previous_status != @complaint.status
        NotificationCreator.call(user: @complaint.reported_by, title: "Complaint status updated", body: "#{@complaint.title} is now #{@complaint.status.humanize}.", type: "complaint", notifiable: @complaint)
        Activity.create!(user: current_user, action: "complaint_updated", description: "#{@complaint.title} moved to #{@complaint.status.humanize}.", trackable: @complaint)
      end
      redirect_to @complaint, notice: "Complaint updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def complaint_scope
    current_user.admin? ? Complaint.all : Complaint.where(reported_by: current_user)
  end

  def complaint_params
    permitted = %i[title description category priority location]
    permitted += %i[status assigned_to_id] if current_user.admin?
    params.require(:complaint).permit(permitted)
  end
end
