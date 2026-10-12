class EventRegistrationService
  Result = Data.define(:success, :registration, :error)

  def initialize(event:, student_profile:)
    @event = event
    @student = student_profile
  end

  def call
    EventRegistration.transaction do
      @event.lock!
      return failure("Registration is closed") if @event.registration_deadline.past? || @event.status != "published"
      return failure("Event is full") if @event.available_seats.zero?
      return failure("You are already registered") if @event.event_registrations.where.not(status: "cancelled").exists?(student_profile: @student)

      registration = @event.event_registrations.find_or_initialize_by(student_profile: @student)
      registration.assign_attributes(status: "registered", registered_at: Time.current)
      registration.save!
      Notification.create!(user: @student.user, title: "Event registration confirmed", body: "You are registered for #{@event.title}.", notification_type: "event", notifiable: @event)
      Result.new(true, registration, nil)
    end
  rescue ActiveRecord::RecordInvalid => error
    failure(error.record.errors.full_messages.to_sentence)
  end

  private

  def failure(message) = Result.new(false, nil, message)
end
