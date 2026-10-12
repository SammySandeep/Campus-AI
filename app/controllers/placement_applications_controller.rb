class PlacementApplicationsController < ApplicationController
  before_action :require_student!

  def create
    drive = PlacementDrive.find(params[:placement_drive_id])
    result = PlacementEligibilityChecker.new(current_user.student_profile, drive).call
    if result.eligible
      drive.placement_applications.create!(student_profile: current_user.student_profile, status: "applied", applied_at: Time.current)
      redirect_to placement_drive_path(drive), notice: "Application submitted."
    else
      redirect_to placement_drive_path(drive), alert: "You are not eligible for this drive."
    end
  rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
    redirect_to placement_drive_path(drive), alert: "You have already applied."
  end

  def destroy
    drive = PlacementDrive.find(params[:placement_drive_id])
    drive.placement_applications.find_by!(student_profile: current_user.student_profile).update!(status: "withdrawn")
    redirect_to placement_drive_path(drive), notice: "Application withdrawn."
  end
end
