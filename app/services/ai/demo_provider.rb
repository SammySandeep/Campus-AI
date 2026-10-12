module Ai
  class DemoProvider
    def ask(user:, question:)
      query = question.downcase
      return capabilities(user) if query.match?(/help|what can you|questions can/)
      return admin_insights(query) if user.admin? && query.match?(/lowest|risk|complaint status/)
      return grading(user, query) if query.match?(/grading|student submission|awaiting review/)
      return projects(user) if query.include?("project") || query.include?("milestone")
      return notifications(user) if query.include?("notification")
      return priorities(user) if query.match?(/focus|priority|priorities/)
      return overview(user) if query.match?(/overview|summary|how am i doing|operations/)
      return attendance(user) if query.include?("attendance")
      return classes(user) if query.include?("class") || query.include?("today")
      return assignments(user) if query.include?("assignment") || query.include?("due")
      return placements(user) if query.match?(/placement|eligible|drive/)
      return events if query.include?("event")
      return complaints(user) if query.include?("complaint")

      capabilities(user)
    end

    private

    def capabilities(user)
      topics = if user.student?
        "classes, attendance, assignment deadlines, projects and milestones, placement eligibility, events, complaints, notifications, and your academic overview"
      elsif user.faculty?
        "today's classes, course attendance, assignments awaiting grading, recent submissions, projects awaiting review, events, and your teaching overview"
      else
        "campus metrics, complaint status, attendance risk, department attendance, events, placement activity, users, and operational priorities"
      end
      "I can answer questions about #{topics}. My answers use only campus data your role is allowed to access."
    end

    def attendance(user)
      if user.student?
        percentage = user.student_profile.attendance_percentage
        warning = percentage < 75 ? " This is below the 75% target, so please review upcoming classes." : " You are currently above the 75% target."
        "Your recorded attendance is #{percentage}%.#{warning}"
      elsif user.faculty?
        sessions = user.faculty_profile.class_sessions.includes(:attendances)
        present = sessions.sum(&:present_count)
        enrolled = sessions.sum(&:enrolled_count)
        "Across your #{sessions.count} class sessions, #{present} present marks have been recorded against #{enrolled} possible enrollee-session records."
      else
        profiles = StudentProfile.includes(:attendances)
        average = profiles.any? ? (profiles.sum(&:attendance_percentage) / profiles.size).round(1) : 0
        "The current student attendance average is #{average}% across #{profiles.size} student profiles."
      end
    end

    def classes(user)
      sessions = if user.student?
        ClassSession.today.joins(course: :enrollments).where(enrollments: { student_profile_id: user.student_profile.id })
      elsif user.faculty?
        user.faculty_profile.class_sessions.today
      else
        ClassSession.today
      end
      return "There are no classes scheduled for today." if sessions.empty?
      sessions.includes(:course).map { |session| "#{session.course.code} at #{session.starts_at.strftime('%I:%M %p')} in #{session.room}" }.join("; ")
    end

    def assignments(user)
      return "Assignment details are available to students and faculty." if user.admin?
      scope = Assignment.published.upcoming.where(due_at: Time.current..1.week.from_now)
      scope = if user.student?
        scope.joins(course: :enrollments).where(enrollments: { student_profile_id: user.student_profile.id })
      else
        scope.where(faculty_profile: user.faculty_profile)
      end
      return "No assignments are due in the next seven days." if scope.empty?
      scope.includes(:course).map { |assignment| "#{assignment.title} (#{assignment.course.code}) — #{assignment.due_at.strftime('%d %b, %I:%M %p')}" }.join("; ")
    end

    def placements(user)
      unless user.student?
        drives = PlacementDrive.active.includes(:company)
        return "There are no active placement drives." if drives.empty?
        return "There are #{drives.size} active placement drives: #{drives.map { |drive| "#{drive.company.name} — #{drive.title}" }.join('; ')}."
      end

      results = PlacementDrive.active.includes(:company, :departments).map do |drive|
        result = PlacementEligibilityChecker.new(user.student_profile, drive).call
        failed = result.reasons.reject { |reason| reason[:passed] }.map { |reason| reason[:message] }
        if result.eligible
          "Eligible — #{drive.company.name}: #{drive.title}"
        else
          "Not eligible — #{drive.company.name}: #{failed.join(', ')}"
        end
      end
      results.any? ? results.join("\n") : "There are no currently open placement drives."
    end

    def events
      events = Event.upcoming.limit(5)
      events.any? ? events.map { |event| "#{event.title} on #{event.starts_at.strftime('%d %b')}" }.join("; ") : "There are no upcoming published events."
    end

    def complaints(user)
      count = user.admin? ? Complaint.active.count : user.reported_complaints.active.count
      "There #{count == 1 ? 'is' : 'are'} #{count} open #{'complaint'.pluralize(count)}#{user.admin? ? ' campus-wide' : ' reported by you'}."
    end

    def projects(user)
      scope = user.student? ? user.student_profile.projects : (user.faculty? ? user.faculty_profile.mentored_projects : Project.all)
      return "There are no projects assigned to your account." if scope.empty?
      scope.includes(:project_milestones).map do |project|
        pending = project.project_milestones.count { |milestone| milestone.status != "completed" }
        "#{project.title} — #{project.status.humanize}, #{pending} open #{'milestone'.pluralize(pending)}"
      end.join("\n")
    end

    def notifications(user)
      unread = user.notifications.unread.recent.limit(5)
      return "You have no unread notifications." if unread.empty?
      "You have #{user.notifications.unread.count} unread notifications:\n#{unread.map { |item| "• #{item.title}: #{item.body}" }.join("\n")}"
    end

    def grading(user, query)
      return "Grading and review queues are available only to faculty and administrators." if user.student?
      if query.include?("review")
        scope = Project.where(status: "submitted")
        scope = scope.where(faculty_profile: user.faculty_profile) if user.faculty?
        return "#{scope.count} #{'project'.pluralize(scope.count)} are awaiting review."
      end

      assignments = user.faculty? ? user.faculty_profile.assignments : Assignment.all
      submissions = Submission.where(assignment: assignments).where(marks: nil).includes(:assignment, student_profile: :user)
      return "There are no submissions awaiting grading." if submissions.empty?
      "#{submissions.count} submissions are awaiting grading. Recent items: #{submissions.limit(5).map { |item| "#{item.student_profile.user.full_name} — #{item.assignment.title}" }.join('; ')}."
    end

    def overview(user)
      stats = DashboardStatistics.new(user).call
      "#{user.student? ? 'Academic' : user.faculty? ? 'Teaching' : 'Campus operations'} overview:\n#{stats.map { |label, value| "• #{label}: #{value}" }.join("\n")}"
    end

    def priorities(user)
      if user.student?
        due = Assignment.published.upcoming.joins(course: :enrollments).where(enrollments: { student_profile_id: user.student_profile.id }).first
        complaint_count = user.reported_complaints.active.count
        "Start with #{due ? "#{due.title}, due #{due.due_at.strftime('%d %b')}" : 'your next scheduled class'}. You also have #{complaint_count} open #{'complaint'.pluralize(complaint_count)} and #{user.notifications.unread.count} unread notifications."
      elsif user.faculty?
        grading_count = Submission.where(assignment: user.faculty_profile.assignments, marks: nil).count
        review_count = Project.where(faculty_profile: user.faculty_profile, status: "submitted").count
        "Your priority queue has #{grading_count} submissions awaiting grading and #{review_count} projects awaiting review."
      else
        "Campus priorities: #{Complaint.active.where(priority: "urgent").count} urgent complaints, #{Complaint.active.count} total open complaints, and #{StudentProfile.all.count { |student| student.attendance_percentage < 75 }} students below 75% recorded attendance."
      end
    end

    def admin_insights(query)
      if query.include?("complaint status")
        counts = Complaint.group(:status).count
        return "Complaint status summary: #{counts.map { |status, count| "#{status.humanize} #{count}" }.join(', ')}."
      end

      department_data = Department.includes(student_profiles: :attendances).map do |department|
        profiles = department.student_profiles
        average = profiles.any? ? (profiles.sum(&:attendance_percentage) / profiles.size).round(1) : 0
        [department, average]
      end
      if query.include?("lowest")
        department, average = department_data.min_by(&:last)
        return department ? "#{department.name} currently has the lowest recorded average attendance at #{average}%." : "No department attendance data is available."
      end

      at_risk = StudentProfile.includes(:user).select { |student| student.attendance_percentage < 75 }
      return "No students are currently below 75% recorded attendance." if at_risk.empty?
      "#{at_risk.size} students are below 75% recorded attendance: #{at_risk.first(8).map { |student| "#{student.user.full_name} (#{student.attendance_percentage}%)" }.join(', ')}."
    end
  end
end
