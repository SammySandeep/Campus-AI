class PlacementDrivesController < ApplicationController
  def index
    @placement_drives = PlacementDrive.active.includes(:company, :departments)
    @eligibility = eligibility_map(@placement_drives) if current_user.student?
  end

  def show
    @placement_drive = PlacementDrive.includes(:company, :departments).find(params[:id])
    if current_user.student?
      @eligibility = PlacementEligibilityChecker.new(current_user.student_profile, @placement_drive).call
      @application = @placement_drive.placement_applications.find_by(student_profile: current_user.student_profile)
    end
  end

  private

  def eligibility_map(drives)
    drives.index_with { |drive| PlacementEligibilityChecker.new(current_user.student_profile, drive).call }
  end
end
