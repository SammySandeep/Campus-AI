class NotificationsController < ApplicationController
  def index
    @notifications = current_user.notifications.recent.limit(100)
  end

  def update
    notification = current_user.notifications.find(params[:id])
    notification.update!(read_at: Time.current)
    redirect_back fallback_location: notifications_path, notice: "Notification marked as read."
  end

  def mark_all_read
    current_user.notifications.unread.update_all(read_at: Time.current)
    redirect_to notifications_path, notice: "All notifications marked as read."
  end
end
