module Api
  module V1
    class MeController < BaseController
      def show
        render json: current_user.as_json(only: %i[id email first_name last_name role], methods: :full_name)
      end
    end
  end
end
