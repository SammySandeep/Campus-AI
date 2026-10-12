class ProfilesController < ApplicationController
  def show
    @profile = current_user.student_profile || current_user.faculty_profile
  end
end
