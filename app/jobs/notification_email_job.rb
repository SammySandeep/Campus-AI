class NotificationEmailJob < ApplicationJob
  queue_as :default

  def perform(mailer_method, user_id, record_type = nil, record_id = nil)
    user = User.find(user_id)
    record = record_type&.constantize&.find(record_id)
    arguments = [user, record].compact
    CampusMailer.public_send(mailer_method, *arguments).deliver_now
  end
end
