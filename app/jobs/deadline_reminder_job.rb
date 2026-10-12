class DeadlineReminderJob < ApplicationJob
  queue_as :default

  def perform
    Assignment.published.where(due_at: Time.current..24.hours.from_now).includes(course: { student_profiles: :user }).find_each do |assignment|
      assignment.course.student_profiles.each do |student|
        next if assignment.submissions.exists?(student_profile: student)
        NotificationCreator.call(user: student.user, title: "Assignment due soon", body: "#{assignment.title} is due within 24 hours.", type: "assignment", notifiable: assignment)
        NotificationEmailJob.perform_later("assignment_deadline", student.user.id, "Assignment", assignment.id)
      end
    end
  end
end
