class NotificationCreator
  def self.call(user:, title:, body:, type: "general", notifiable: nil)
    Notification.create!(user: user, title: title, body: body, notification_type: type, notifiable: notifiable)
  end
end
