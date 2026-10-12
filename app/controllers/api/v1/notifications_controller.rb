module Api
  module V1
    class NotificationsController < BaseController
      def index
        render json: current_user.notifications.recent.limit(50).as_json(only: %i[id title body notification_type read_at created_at])
      end
    end
  end
end
