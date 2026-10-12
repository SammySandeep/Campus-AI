module Api
  module V1
    class BaseController < ApplicationController
      protect_from_forgery with: :null_session

      private

      def authenticate_user!
        super
      end
    end
  end
end
