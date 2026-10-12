class EventRegistrationsController < ApplicationController
  before_action :require_student!

  def create
    event = Event.find(params[:event_id])
    result = EventRegistrationService.new(event: event, student_profile: current_user.student_profile).call
    redirect_to event, (result.success ? { notice: "Registration confirmed." } : { alert: result.error })
  end

  def destroy
    event = Event.find(params[:event_id])
    registration = event.event_registrations.find_by!(student_profile: current_user.student_profile, status: "registered")
    registration.update!(status: "cancelled")
    redirect_to event, notice: "Registration cancelled."
  end
end
