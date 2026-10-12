module Api
  module V1
    class PlacementDrivesController < BaseController
      def index
        render json: PlacementDrive.active.includes(:company).map { |drive| { id: drive.id, title: drive.title, company: drive.company.name, deadline: drive.registration_deadline } }
      end
    end
  end
end
