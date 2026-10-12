class EventsController < ApplicationController
  def index
    @events = Event.upcoming.includes(:event_registrations)
  end

  def show
    @event = Event.published.includes(event_registrations: { student_profile: :user }).find(params[:id])
    @registration = current_user.student? ? @event.event_registrations.find_by(student_profile: current_user.student_profile, status: "registered") : nil
  end
end
