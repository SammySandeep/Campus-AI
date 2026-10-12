module Admin
  class OverviewController < BaseController
    def index
      @stats = DashboardStatistics.new(current_user).call
      @activities = Activity.recent.limit(20)
      @complaint_counts = Complaint.group(:status).count
    end
  end
end
