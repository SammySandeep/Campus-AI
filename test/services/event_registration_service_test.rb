require "test_helper"

class EventRegistrationServiceTest < ActiveSupport::TestCase
  test "does not exceed event capacity" do
    organizer = User.create!(email: "organizer@example.com", password: "password123", first_name: "Event", last_name: "Admin", role: :super_admin)
    event = Event.create!(title: "Workshop", location: "Lab", starts_at: 3.days.from_now, ends_at: 3.days.from_now + 2.hours, capacity: 1, registration_deadline: 2.days.from_now, status: "published", organizer: organizer)
    _first_user, first = student
    _second_user, second = student

    assert EventRegistrationService.new(event: event, student_profile: first).call.success
    result = EventRegistrationService.new(event: event, student_profile: second).call
    assert_not result.success
    assert_equal "Event is full", result.error
  end
end
