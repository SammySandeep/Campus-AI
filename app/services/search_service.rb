class SearchService
  def initialize(user:, query:)
    @user = user
    @query = query.to_s.strip
  end

  def call
    return {} if @query.blank?
    pattern = "%#{ActiveRecord::Base.sanitize_sql_like(@query.downcase)}%"
    {
      "Courses" => course_scope.where("LOWER(name) LIKE :q OR LOWER(code) LIKE :q", q: pattern).limit(10),
      "Events" => Event.published.where("LOWER(title) LIKE ?", pattern).limit(10),
      "Projects" => project_scope.where("LOWER(title) LIKE ?", pattern).limit(10),
      "Placements" => PlacementDrive.joins(:company).where("LOWER(placement_drives.title) LIKE :q OR LOWER(companies.name) LIKE :q", q: pattern).limit(10),
      "Helpdesk" => complaint_scope.where("LOWER(title) LIKE ?", pattern).limit(10),
      "Documents" => Document.visible_to(@user).where("LOWER(title) LIKE :q OR LOWER(description) LIKE :q", q: pattern).limit(10)
    }
  end

  private

  def course_scope
    return Course.all if @user.admin?
    return @user.faculty_profile.courses if @user.faculty?
    @user.student_profile.courses
  end

  def project_scope
    @user.student? ? @user.student_profile.projects : Project.all
  end

  def complaint_scope
    @user.admin? ? Complaint.all : Complaint.where(reported_by: @user)
  end
end
