class CampusMailer < ApplicationMailer
  def welcome(user)
    simple_mail(user, "Welcome to Campus AI Command Center", "Your campus account is ready. Sign in to view your personalized dashboard.")
  end

  def assignment_deadline(user, assignment)
    simple_mail(user, "Assignment deadline reminder", "#{assignment.title} is due on #{assignment.due_at.strftime('%d %B at %I:%M %p')}.")
  end

  def event_registration(user, event)
    simple_mail(user, "Event registration confirmed", "Your registration for #{event.title} is confirmed.")
  end

  def complaint_status(user, complaint)
    simple_mail(user, "Complaint status updated", "#{complaint.title} is now #{complaint.status.humanize}.")
  end

  def placement_application(user, application)
    simple_mail(user, "Placement application updated", "Your application for #{application.placement_drive.title} is now #{application.status.humanize}.")
  end

  private

  def simple_mail(user, subject, body)
    mail(to: user.email, subject: subject) { |format| format.text { render plain: "Hello #{user.first_name},\n\n#{body}\n\nCampus AI Command Center" } }
  end
end
