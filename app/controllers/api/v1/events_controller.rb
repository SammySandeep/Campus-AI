module Api
  module V1
    class EventsController < BaseController
      def index
        render json: Event.upcoming.as_json(only: %i[id title location starts_at ends_at capacity registration_deadline])
      end
    end
  end
end
