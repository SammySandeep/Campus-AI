puts "Resetting demo data…"

models = [ComplaintComment, Attendance, Submission, ProjectReview, ProjectSubmission, ProjectMilestone,
  ProjectMembership, EventRegistration, PlacementApplication, PlacementDriveDepartment, Notification,
  Activity, Enrollment, ClassSession, Assignment, Project, Complaint, PlacementDrive, Company, Event,
  Document, Course, StudentProfile, FacultyProfile, User, Department]
ActiveRecord::Base.connection.disable_referential_integrity { models.each(&:delete_all) }

password = "password123"

cse = Department.create!(name: "Computer Science and Engineering", code: "CSE", description: "Computing, AI, software systems, and data engineering.")
ece = Department.create!(name: "Electronics and Communication Engineering", code: "ECE", description: "Communication systems, embedded design, and electronics.")
mech = Department.create!(name: "Mechanical Engineering", code: "ME", description: "Design, manufacturing, thermal systems, and robotics.")

superadmin = User.create!(email: "superadmin@example.com", password: password, first_name: "Aarav", last_name: "Rao", role: :super_admin)
admin = User.create!(email: "admin@example.com", password: password, first_name: "Meera", last_name: "Iyer", role: :department_admin)
FacultyProfile.create!(user: admin, department: cse, employee_id: "ADM001", designation: "Department Administrator")

faculty_data = [
  ["faculty@example.com", "Ananya", "Sharma", cse, "FAC001", "Associate Professor"],
  ["vivek.faculty@example.com", "Vivek", "Menon", cse, "FAC002", "Assistant Professor"],
  ["priya.faculty@example.com", "Priya", "Nair", ece, "FAC003", "Professor"],
  ["rohan.faculty@example.com", "Rohan", "Kulkarni", ece, "FAC004", "Assistant Professor"],
  ["kavya.faculty@example.com", "Kavya", "Singh", mech, "FAC005", "Associate Professor"],
  ["arjun.faculty@example.com", "Arjun", "Desai", mech, "FAC006", "Assistant Professor"]
]
faculty = faculty_data.map do |email, first, last, department, employee_id, designation|
  user = User.create!(email: email, password: password, first_name: first, last_name: last, role: :faculty)
  FacultyProfile.create!(user: user, department: department, employee_id: employee_id, designation: designation)
end

student_names = [
  ["student@example.com", "Nisha", "Patel"], ["aditya@example.com", "Aditya", "Joshi"],
  ["saanvi@example.com", "Saanvi", "Gupta"], ["ishaan@example.com", "Ishaan", "Verma"],
  ["diya@example.com", "Diya", "Reddy"], ["kabir@example.com", "Kabir", "Shah"],
  ["anya@example.com", "Anya", "Bose"], ["reyansh@example.com", "Reyansh", "Kumar"],
  ["myra@example.com", "Myra", "Kapoor"], ["vivaan@example.com", "Vivaan", "Mehta"],
  ["tara@example.com", "Tara", "Pillai"], ["dev@example.com", "Dev", "Mishra"],
  ["riya@example.com", "Riya", "Das"], ["vihaan@example.com", "Vihaan", "Jain"],
  ["meher@example.com", "Meher", "Saxena"], ["atharv@example.com", "Atharv", "Bhat"],
  ["navya@example.com", "Navya", "Chopra"], ["arush@example.com", "Arush", "Gowda"],
  ["isha@example.com", "Isha", "Kohli"], ["dhruv@example.com", "Dhruv", "Malhotra"],
  ["kiara@example.com", "Kiara", "Sethi"], ["om@example.com", "Om", "Chandra"],
  ["aadhya@example.com", "Aadhya", "Roy"], ["yash@example.com", "Yash", "Pandey"]
]

students = student_names.each_with_index.map do |(email, first, last), index|
  department = [cse, ece, mech][index / 8]
  user = User.create!(email: email, password: password, first_name: first, last_name: last, role: :student)
  StudentProfile.create!(user: user, department: department, roll_number: "#{department.code}#{2023 + index % 2}#{format('%03d', index + 1)}",
    semester: index.even? ? 6 : 4, graduation_year: index < 16 ? 2027 : 2028,
    cgpa: (7.0 + (index % 9) * 0.25).round(2), active_backlogs: index % 7 == 0 ? 1 : 0,
    phone: "90000#{format('%05d', index + 1)}")
end

courses = [
  Course.create!(name: "Artificial Intelligence", code: "CS601", semester: 6, credits: 4, department: cse, faculty_profile: faculty[0]),
  Course.create!(name: "Web Application Engineering", code: "CS602", semester: 6, credits: 4, department: cse, faculty_profile: faculty[1]),
  Course.create!(name: "Digital Signal Processing", code: "EC601", semester: 6, credits: 4, department: ece, faculty_profile: faculty[2]),
  Course.create!(name: "Embedded Systems", code: "EC602", semester: 6, credits: 3, department: ece, faculty_profile: faculty[3]),
  Course.create!(name: "Robotics and Automation", code: "ME601", semester: 6, credits: 4, department: mech, faculty_profile: faculty[4]),
  Course.create!(name: "Computer Aided Design", code: "ME602", semester: 6, credits: 3, department: mech, faculty_profile: faculty[5])
]

students.each do |student|
  courses.select { |course| course.department_id == student.department_id }.each do |course|
    Enrollment.create!(student_profile: student, course: course, academic_year: "2026-27", status: "active")
  end
end

sessions = []
courses.each_with_index do |course, index|
  sessions << ClassSession.create!(course: course, faculty_profile: course.faculty_profile, session_date: Date.current,
    starts_at: Time.zone.parse("#{9 + index % 4}:00"), ends_at: Time.zone.parse("#{10 + index % 4}:00"), room: "Block #{('A'.ord + index).chr}-#{201 + index}", status: index.zero? ? "open" : "scheduled",
    attendance_expires_at: index.zero? ? 2.hours.from_now : nil)
  sessions << ClassSession.create!(course: course, faculty_profile: course.faculty_profile, session_date: 2.days.ago.to_date,
    starts_at: Time.zone.parse("10:00"), ends_at: Time.zone.parse("11:00"), room: "Lab #{index + 1}", status: "closed", attendance_expires_at: 2.days.ago)
end

sessions.select { |session| session.status == "closed" }.each do |session|
  session.course.student_profiles.first(6).each_with_index do |student, index|
    Attendance.create!(class_session: session, student_profile: student, status: index == 5 ? "absent" : "present", marked_at: session.session_date.to_time + 10.hours)
  end
end

assignments = 8.times.map do |index|
  course = courses[index % courses.length]
  Assignment.create!(course: course, faculty_profile: course.faculty_profile, title: ["AI Ethics Case Study", "Rails Service Object", "Signal Filter Design", "Sensor Interface Lab", "Robot Path Planner", "CAD Assembly", "Neural Network Notebook", "Hotwire Dashboard"][index],
    description: "Apply concepts from #{course.name} to a practical campus scenario. Submit a concise report with evidence of your implementation.",
    due_at: (index + 2).days.from_now.change(hour: 23, min: 59), maximum_marks: 50 + (index % 2) * 50, published: true)
end
assignments.first(5).each do |assignment|
  assignment.course.student_profiles.first(3).each_with_index do |student, index|
    Submission.create!(assignment: assignment, student_profile: student, submitted_at: (index + 1).hours.ago, status: index.zero? ? "graded" : "submitted", marks: index.zero? ? assignment.maximum_marks * 0.86 : nil, feedback: index.zero? ? "Clear reasoning and a strong implementation." : nil)
  end
end

project_titles = ["Smart Campus Energy Monitor", "AI Study Companion", "Autonomous Library Cart", "Community Water Quality Sensor"]
projects = project_titles.each_with_index.map do |title, index|
  project = Project.create!(title: title, description: "A multidisciplinary student project focused on measurable campus impact, responsible engineering, and maintainable implementation.", status: %w[in_progress submitted approved completed][index], faculty_profile: faculty[index], academic_year: "2026-27")
  students.slice(index * 3, 3).each_with_index { |student, member_index| ProjectMembership.create!(project: project, student_profile: student, team_role: member_index.zero? ? "Team Lead" : "Developer") }
  ProjectMilestone.create!(project: project, title: "Prototype demonstration", description: "Demonstrate the core workflow.", due_at: (index + 2).weeks.from_now, status: index > 1 ? "completed" : "in_progress")
  ProjectReview.create!(project: project, faculty_profile: faculty[index], comments: "Good progress. Strengthen validation and document the evaluation results.", score: 78 + index * 4, reviewed_at: index.days.ago) if index.positive?
  project
end

events = 6.times.map do |index|
  Event.create!(title: ["Campus AI Hackathon", "Open Source Sprint", "Cultural Night", "Robotics Workshop", "Startup Founders Forum", "Green Campus Drive"][index],
    description: "An inclusive campus experience designed for hands-on learning, collaboration, and meaningful connections.", location: ["Innovation Lab", "Seminar Hall", "Main Auditorium", "Robotics Lab", "Incubation Center", "Central Quadrangle"][index],
    starts_at: (index + 2).days.from_now.change(hour: 10 + index), ends_at: (index + 2).days.from_now.change(hour: 13 + index), capacity: 40 + index * 15,
    registration_deadline: (index + 1).days.from_now.change(hour: 20), status: "published", organizer: index.even? ? admin : superadmin)
end
events.each_with_index do |event, event_index|
  students.first(3 + event_index).each { |student| EventRegistration.create!(event: event, student_profile: student, status: "registered", registered_at: 1.day.ago) }
end

10.times do |index|
  status = %w[open assigned in_progress resolved closed][index % 5]
  complaint = Complaint.create!(title: ["Wi-Fi outage in library", "Projector needs repair", "Hostel water cooler", "Lab power socket", "Broken pathway light", "Portal login issue", "Classroom fan noise", "Cafeteria wash station", "Workshop ventilation", "Sports equipment request"][index],
    description: "Please inspect this issue and share an estimated resolution timeline with the reporting student.", category: %w[IT classroom hostel electrical infrastructure other][index % 6], priority: %w[medium high low urgent][index % 4], status: status,
    location: "Campus Zone #{index + 1}", reported_by: students[index].user, assigned_to: index.even? ? admin : faculty[index % faculty.length].user,
    resolved_at: status.in?(%w[resolved closed]) ? 1.day.ago : nil)
  ComplaintComment.create!(complaint: complaint, user: complaint.assigned_to, body: "The support team has reviewed this ticket and added it to the current work queue.")
end

companies = ["Infosys", "Tata Consultancy Services", "Zoho", "Bosch India", "Freshworks"].map { |name| Company.create!(name: name, website: "https://example.com", description: "A demo recruiting partner offering graduate engineering roles.") }
drives = companies.each_with_index.map do |company, index|
  drive = PlacementDrive.create!(company: company, title: ["Graduate Engineer Program", "Digital Engineering Drive", "Product Developer Hiring", "Mobility Systems Campus Drive", "Software Engineer Campus Hiring"][index],
    description: "Campus recruitment for graduating students, including aptitude, technical, and interview rounds.", minimum_cgpa: 6.5 + index * 0.35, maximum_backlogs: index.zero? ? 1 : 0,
    graduation_year: index < 4 ? 2027 : 2028, registration_deadline: (index + 5).days.from_now, drive_date: (index + 12).days.from_now, status: "open")
  allowed = index.even? ? [cse, ece, mech] : [cse, ece]
  allowed.each { |department| PlacementDriveDepartment.create!(placement_drive: drive, department: department) }
  drive
end
drives.first(2).each_with_index { |drive, index| PlacementApplication.create!(placement_drive: drive, student_profile: students[index + 1], status: index.zero? ? "shortlisted" : "applied", applied_at: 2.days.ago) }

6.times do |index|
  Document.create!(title: ["Academic Calendar 2026-27", "Placement Preparation Guide", "Campus IT Policy", "Project Review Rubric", "Event Safety Checklist", "Student Wellness Resources"][index],
    category: %w[Academic Placement Policy Projects Events Wellness][index], description: "Official demo metadata for a commonly used campus resource.", uploaded_by: admin,
    visibility: %w[everyone students everyone faculty admins everyone][index])
end

students.first(8).each_with_index do |student, index|
  Notification.create!(user: student.user, title: index.even? ? "Assignment due soon" : "New campus event", body: index.even? ? assignments[index].title : events[index % events.length].title,
    notification_type: index.even? ? "assignment" : "event", notifiable: index.even? ? assignments[index] : events[index % events.length], read_at: index > 4 ? Time.current : nil)
end

[
  [admin, "event_published", "Campus AI Hackathon registration is now open.", events.first],
  [faculty.first.user, "assignment_created", "AI Ethics Case Study was published.", assignments.first],
  [students.first.user, "project_submitted", "Smart Campus Energy Monitor reached its prototype milestone.", projects.first],
  [admin, "placement_opened", "Infosys Graduate Engineer Program opened for applications.", drives.first]
].each { |user, action, description, trackable| Activity.create!(user: user, action: action, description: description, trackable: trackable) }

puts <<~CREDENTIALS

  Campus AI Command Center demo data is ready.

  DEMO ACCOUNTS (development only)
  Student:    student@example.com / #{password}
  Faculty:    faculty@example.com / #{password}
  Admin:      admin@example.com / #{password}
  Super Admin: superadmin@example.com / #{password}
CREDENTIALS
