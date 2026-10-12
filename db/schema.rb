# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_10_10_065941) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activities", force: :cascade do |t|
    t.integer "user_id"
    t.string "action", null: false
    t.text "description", null: false
    t.string "trackable_type"
    t.integer "trackable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trackable_type", "trackable_id"], name: "index_activities_on_trackable"
    t.index ["user_id"], name: "index_activities_on_user_id"
  end

  create_table "assignments", force: :cascade do |t|
    t.integer "course_id", null: false
    t.integer "faculty_profile_id", null: false
    t.string "title", null: false
    t.text "description"
    t.datetime "due_at", null: false
    t.integer "maximum_marks", default: 100, null: false
    t.boolean "published", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_assignments_on_course_id"
    t.index ["faculty_profile_id"], name: "index_assignments_on_faculty_profile_id"
  end

  create_table "attendances", force: :cascade do |t|
    t.integer "class_session_id", null: false
    t.integer "student_profile_id", null: false
    t.string "status", default: "present", null: false
    t.datetime "marked_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["class_session_id", "student_profile_id"], name: "index_attendances_on_class_session_id_and_student_profile_id", unique: true
    t.index ["class_session_id"], name: "index_attendances_on_class_session_id"
    t.index ["student_profile_id"], name: "index_attendances_on_student_profile_id"
  end

  create_table "class_sessions", force: :cascade do |t|
    t.integer "course_id", null: false
    t.integer "faculty_profile_id", null: false
    t.date "session_date", null: false
    t.time "starts_at", null: false
    t.time "ends_at", null: false
    t.string "room"
    t.string "attendance_token", null: false
    t.datetime "attendance_expires_at"
    t.string "status", default: "scheduled", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attendance_token"], name: "index_class_sessions_on_attendance_token", unique: true
    t.index ["course_id"], name: "index_class_sessions_on_course_id"
    t.index ["faculty_profile_id"], name: "index_class_sessions_on_faculty_profile_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name", null: false
    t.string "website"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_companies_on_name", unique: true
  end

  create_table "complaint_comments", force: :cascade do |t|
    t.integer "complaint_id", null: false
    t.integer "user_id", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["complaint_id"], name: "index_complaint_comments_on_complaint_id"
    t.index ["user_id"], name: "index_complaint_comments_on_user_id"
  end

  create_table "complaints", force: :cascade do |t|
    t.string "title", null: false
    t.text "description", null: false
    t.string "category", null: false
    t.string "priority", default: "medium", null: false
    t.string "status", default: "open", null: false
    t.string "location"
    t.integer "reported_by_id", null: false
    t.integer "assigned_to_id"
    t.datetime "resolved_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assigned_to_id"], name: "index_complaints_on_assigned_to_id"
    t.index ["reported_by_id"], name: "index_complaints_on_reported_by_id"
  end

  create_table "courses", force: :cascade do |t|
    t.integer "department_id", null: false
    t.integer "faculty_profile_id"
    t.string "name", null: false
    t.string "code", null: false
    t.integer "semester", null: false
    t.integer "credits", default: 3, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_courses_on_code", unique: true
    t.index ["department_id"], name: "index_courses_on_department_id"
    t.index ["faculty_profile_id"], name: "index_courses_on_faculty_profile_id"
  end

  create_table "departments", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_departments_on_code", unique: true
  end

  create_table "documents", force: :cascade do |t|
    t.string "title", null: false
    t.string "category", null: false
    t.text "description"
    t.integer "uploaded_by_id", null: false
    t.string "visibility", default: "everyone", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uploaded_by_id"], name: "index_documents_on_uploaded_by_id"
  end

  create_table "enrollments", force: :cascade do |t|
    t.integer "student_profile_id", null: false
    t.integer "course_id", null: false
    t.string "academic_year", null: false
    t.string "status", default: "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_enrollments_on_course_id"
    t.index ["student_profile_id", "course_id", "academic_year"], name: "idx_unique_course_enrollment", unique: true
    t.index ["student_profile_id"], name: "index_enrollments_on_student_profile_id"
  end

  create_table "event_registrations", force: :cascade do |t|
    t.integer "event_id", null: false
    t.integer "student_profile_id", null: false
    t.string "status", default: "registered", null: false
    t.datetime "registered_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id", "student_profile_id"], name: "index_event_registrations_on_event_id_and_student_profile_id", unique: true
    t.index ["event_id"], name: "index_event_registrations_on_event_id"
    t.index ["student_profile_id"], name: "index_event_registrations_on_student_profile_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.string "location", null: false
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.integer "capacity", null: false
    t.datetime "registration_deadline", null: false
    t.string "status", default: "draft", null: false
    t.integer "organizer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organizer_id"], name: "index_events_on_organizer_id"
  end

  create_table "faculty_profiles", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "department_id", null: false
    t.string "employee_id", null: false
    t.string "designation", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_faculty_profiles_on_department_id"
    t.index ["employee_id"], name: "index_faculty_profiles_on_employee_id", unique: true
    t.index ["user_id"], name: "index_faculty_profiles_on_user_id", unique: true
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "title", null: false
    t.text "body", null: false
    t.string "notification_type", default: "general", null: false
    t.datetime "read_at"
    t.string "notifiable_type"
    t.integer "notifiable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable"
    t.index ["user_id", "read_at"], name: "index_notifications_on_user_id_and_read_at"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "placement_applications", force: :cascade do |t|
    t.integer "placement_drive_id", null: false
    t.integer "student_profile_id", null: false
    t.string "status", default: "applied", null: false
    t.datetime "applied_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["placement_drive_id", "student_profile_id"], name: "idx_unique_placement_application", unique: true
    t.index ["placement_drive_id"], name: "index_placement_applications_on_placement_drive_id"
    t.index ["student_profile_id"], name: "index_placement_applications_on_student_profile_id"
  end

  create_table "placement_drive_departments", force: :cascade do |t|
    t.integer "placement_drive_id", null: false
    t.integer "department_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_placement_drive_departments_on_department_id"
    t.index ["placement_drive_id", "department_id"], name: "idx_unique_drive_department", unique: true
    t.index ["placement_drive_id"], name: "index_placement_drive_departments_on_placement_drive_id"
  end

  create_table "placement_drives", force: :cascade do |t|
    t.integer "company_id", null: false
    t.string "title", null: false
    t.text "description"
    t.decimal "minimum_cgpa", precision: 4, scale: 2, default: "0.0", null: false
    t.integer "maximum_backlogs", default: 0, null: false
    t.integer "graduation_year", null: false
    t.datetime "registration_deadline", null: false
    t.datetime "drive_date", null: false
    t.string "status", default: "draft", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_placement_drives_on_company_id"
  end

  create_table "project_memberships", force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "student_profile_id", null: false
    t.string "team_role", default: "member", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id", "student_profile_id"], name: "index_project_memberships_on_project_id_and_student_profile_id", unique: true
    t.index ["project_id"], name: "index_project_memberships_on_project_id"
    t.index ["student_profile_id"], name: "index_project_memberships_on_student_profile_id"
  end

  create_table "project_milestones", force: :cascade do |t|
    t.integer "project_id", null: false
    t.string "title", null: false
    t.text "description"
    t.datetime "due_at", null: false
    t.string "status", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_project_milestones_on_project_id"
  end

  create_table "project_reviews", force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "faculty_profile_id", null: false
    t.text "comments", null: false
    t.integer "score"
    t.datetime "reviewed_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["faculty_profile_id"], name: "index_project_reviews_on_faculty_profile_id"
    t.index ["project_id"], name: "index_project_reviews_on_project_id"
  end

  create_table "project_submissions", force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "project_milestone_id"
    t.datetime "submitted_at", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_project_submissions_on_project_id"
    t.index ["project_milestone_id"], name: "index_project_submissions_on_project_milestone_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.string "status", default: "proposed", null: false
    t.integer "faculty_profile_id"
    t.string "academic_year", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["faculty_profile_id"], name: "index_projects_on_faculty_profile_id"
  end

  create_table "student_profiles", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "department_id", null: false
    t.string "roll_number", null: false
    t.integer "semester", null: false
    t.integer "graduation_year", null: false
    t.decimal "cgpa", precision: 4, scale: 2, default: "0.0", null: false
    t.integer "active_backlogs", default: 0, null: false
    t.string "phone"
    t.date "date_of_birth"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_student_profiles_on_department_id"
    t.index ["roll_number"], name: "index_student_profiles_on_roll_number", unique: true
    t.index ["user_id"], name: "index_student_profiles_on_user_id", unique: true
  end

  create_table "submissions", force: :cascade do |t|
    t.integer "assignment_id", null: false
    t.integer "student_profile_id", null: false
    t.datetime "submitted_at"
    t.string "status", default: "submitted", null: false
    t.decimal "marks", precision: 6, scale: 2
    t.text "feedback"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assignment_id", "student_profile_id"], name: "index_submissions_on_assignment_id_and_student_profile_id", unique: true
    t.index ["assignment_id"], name: "index_submissions_on_assignment_id"
    t.index ["student_profile_id"], name: "index_submissions_on_student_profile_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.integer "role", default: 0, null: false
    t.boolean "active", default: true, null: false
    t.datetime "last_login_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "activities", "users"
  add_foreign_key "assignments", "courses"
  add_foreign_key "assignments", "faculty_profiles"
  add_foreign_key "attendances", "class_sessions"
  add_foreign_key "attendances", "student_profiles"
  add_foreign_key "class_sessions", "courses"
  add_foreign_key "class_sessions", "faculty_profiles"
  add_foreign_key "complaint_comments", "complaints"
  add_foreign_key "complaint_comments", "users"
  add_foreign_key "complaints", "users", column: "assigned_to_id"
  add_foreign_key "complaints", "users", column: "reported_by_id"
  add_foreign_key "courses", "departments"
  add_foreign_key "courses", "faculty_profiles"
  add_foreign_key "documents", "users", column: "uploaded_by_id"
  add_foreign_key "enrollments", "courses"
  add_foreign_key "enrollments", "student_profiles"
  add_foreign_key "event_registrations", "events"
  add_foreign_key "event_registrations", "student_profiles"
  add_foreign_key "events", "users", column: "organizer_id"
  add_foreign_key "faculty_profiles", "departments"
  add_foreign_key "faculty_profiles", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "placement_applications", "placement_drives", column: "placement_drive_id"
  add_foreign_key "placement_applications", "student_profiles"
  add_foreign_key "placement_drive_departments", "departments"
  add_foreign_key "placement_drive_departments", "placement_drives", column: "placement_drive_id"
  add_foreign_key "placement_drives", "companies"
  add_foreign_key "project_memberships", "projects"
  add_foreign_key "project_memberships", "student_profiles"
  add_foreign_key "project_milestones", "projects"
  add_foreign_key "project_reviews", "faculty_profiles"
  add_foreign_key "project_reviews", "projects"
  add_foreign_key "project_submissions", "project_milestones"
  add_foreign_key "project_submissions", "projects"
  add_foreign_key "projects", "faculty_profiles"
  add_foreign_key "student_profiles", "departments"
  add_foreign_key "student_profiles", "users"
  add_foreign_key "submissions", "assignments"
  add_foreign_key "submissions", "student_profiles"
end
