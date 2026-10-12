module Admin
  class DepartmentsController < BaseController
    before_action :set_department, only: %i[edit update]

    def index
      @departments = Department.includes(:student_profiles, :faculty_profiles, :courses)
    end

    def new
      @department = Department.new
    end

    def create
      @department = Department.new(department_params)
      @department.save ? redirect_to(admin_departments_path, notice: "Department created.") : render(:new, status: :unprocessable_entity)
    end

    def edit; end

    def update
      @department.update(department_params) ? redirect_to(admin_departments_path, notice: "Department updated.") : render(:edit, status: :unprocessable_entity)
    end

    private

    def set_department = @department = Department.find(params[:id])
    def department_params = params.require(:department).permit(:name, :code, :description)
  end
end
