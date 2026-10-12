module Admin
  class UsersController < BaseController
    def index
      @users = User.includes(:student_profile, :faculty_profile).order(:role, :first_name)
    end

    def show
      @user = User.find(params[:id])
    end

    def update
      @user = User.find(params[:id])
      permitted = current_user.super_admin? ? %i[first_name last_name active role] : %i[first_name last_name active]
      if @user.update(params.require(:user).permit(permitted))
        redirect_to admin_user_path(@user), notice: "User updated."
      else
        render :show, status: :unprocessable_entity
      end
    end
  end
end
