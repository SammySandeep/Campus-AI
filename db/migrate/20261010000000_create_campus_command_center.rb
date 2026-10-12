class CreateCampusCommandCenter < ActiveRecord::Migration[8.0]
  def change
    create_table :departments do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.text :description
      t.timestamps
    end
    add_index :departments, :code, unique: true

    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.integer :role, null: false, default: 0
      t.boolean :active, null: false, default: true
      t.datetime :last_login_at
      t.timestamps
    end
    add_index :users, :email, unique: true

    create_table :student_profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.references :department, null: false, foreign_key: true
      t.string :roll_number, null: false
      t.integer :semester, null: false
      t.integer :graduation_year, null: false
      t.decimal :cgpa, precision: 4, scale: 2, null: false, default: 0
      t.integer :active_backlogs, null: false, default: 0
      t.string :phone
      t.date :date_of_birth
      t.timestamps
    end
    add_index :student_profiles, :roll_number, unique: true

    create_table :faculty_profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.references :department, null: false, foreign_key: true
      t.string :employee_id, null: false
      t.string :designation, null: false
      t.timestamps
    end
    add_index :faculty_profiles, :employee_id, unique: true

    create_table :courses do |t|
      t.references :department, null: false, foreign_key: true
      t.references :faculty_profile, foreign_key: true
      t.string :name, null: false
      t.string :code, null: false
      t.integer :semester, null: false
      t.integer :credits, null: false, default: 3
      t.timestamps
    end
    add_index :courses, :code, unique: true

    create_table :enrollments do |t|
      t.references :student_profile, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.string :academic_year, null: false
      t.string :status, null: false, default: "active"
      t.timestamps
    end
    add_index :enrollments, [:student_profile_id, :course_id, :academic_year], unique: true, name: "idx_unique_course_enrollment"

    create_table :class_sessions do |t|
      t.references :course, null: false, foreign_key: true
      t.references :faculty_profile, null: false, foreign_key: true
      t.date :session_date, null: false
      t.time :starts_at, null: false
      t.time :ends_at, null: false
      t.string :room
      t.string :attendance_token, null: false
      t.datetime :attendance_expires_at
      t.string :status, null: false, default: "scheduled"
      t.timestamps
    end
    add_index :class_sessions, :attendance_token, unique: true

    create_table :attendances do |t|
      t.references :class_session, null: false, foreign_key: true
      t.references :student_profile, null: false, foreign_key: true
      t.string :status, null: false, default: "present"
      t.datetime :marked_at, null: false
      t.timestamps
    end
    add_index :attendances, [:class_session_id, :student_profile_id], unique: true

    create_table :assignments do |t|
      t.references :course, null: false, foreign_key: true
      t.references :faculty_profile, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.datetime :due_at, null: false
      t.integer :maximum_marks, null: false, default: 100
      t.boolean :published, null: false, default: false
      t.timestamps
    end

    create_table :submissions do |t|
      t.references :assignment, null: false, foreign_key: true
      t.references :student_profile, null: false, foreign_key: true
      t.datetime :submitted_at
      t.string :status, null: false, default: "submitted"
      t.decimal :marks, precision: 6, scale: 2
      t.text :feedback
      t.timestamps
    end
    add_index :submissions, [:assignment_id, :student_profile_id], unique: true

    create_table :projects do |t|
      t.string :title, null: false
      t.text :description
      t.string :status, null: false, default: "proposed"
      t.references :faculty_profile, foreign_key: true
      t.string :academic_year, null: false
      t.timestamps
    end

    create_table :project_memberships do |t|
      t.references :project, null: false, foreign_key: true
      t.references :student_profile, null: false, foreign_key: true
      t.string :team_role, null: false, default: "member"
      t.timestamps
    end
    add_index :project_memberships, [:project_id, :student_profile_id], unique: true

    create_table :project_milestones do |t|
      t.references :project, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.datetime :due_at, null: false
      t.string :status, null: false, default: "pending"
      t.timestamps
    end

    create_table :project_submissions do |t|
      t.references :project, null: false, foreign_key: true
      t.references :project_milestone, foreign_key: true
      t.datetime :submitted_at, null: false
      t.text :notes
      t.timestamps
    end

    create_table :project_reviews do |t|
      t.references :project, null: false, foreign_key: true
      t.references :faculty_profile, null: false, foreign_key: true
      t.text :comments, null: false
      t.integer :score
      t.datetime :reviewed_at, null: false
      t.timestamps
    end

    create_table :events do |t|
      t.string :title, null: false
      t.text :description
      t.string :location, null: false
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.integer :capacity, null: false
      t.datetime :registration_deadline, null: false
      t.string :status, null: false, default: "draft"
      t.references :organizer, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end

    create_table :event_registrations do |t|
      t.references :event, null: false, foreign_key: true
      t.references :student_profile, null: false, foreign_key: true
      t.string :status, null: false, default: "registered"
      t.datetime :registered_at, null: false
      t.timestamps
    end
    add_index :event_registrations, [:event_id, :student_profile_id], unique: true

    create_table :complaints do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.string :category, null: false
      t.string :priority, null: false, default: "medium"
      t.string :status, null: false, default: "open"
      t.string :location
      t.references :reported_by, null: false, foreign_key: { to_table: :users }
      t.references :assigned_to, foreign_key: { to_table: :users }
      t.datetime :resolved_at
      t.timestamps
    end

    create_table :complaint_comments do |t|
      t.references :complaint, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :body, null: false
      t.timestamps
    end

    create_table :companies do |t|
      t.string :name, null: false
      t.string :website
      t.text :description
      t.timestamps
    end
    add_index :companies, :name, unique: true

    create_table :placement_drives do |t|
      t.references :company, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.decimal :minimum_cgpa, precision: 4, scale: 2, null: false, default: 0
      t.integer :maximum_backlogs, null: false, default: 0
      t.integer :graduation_year, null: false
      t.datetime :registration_deadline, null: false
      t.datetime :drive_date, null: false
      t.string :status, null: false, default: "draft"
      t.timestamps
    end

    create_table :placement_drive_departments do |t|
      t.references :placement_drive, null: false, foreign_key: true
      t.references :department, null: false, foreign_key: true
      t.timestamps
    end
    add_index :placement_drive_departments, [:placement_drive_id, :department_id], unique: true, name: "idx_unique_drive_department"

    create_table :placement_applications do |t|
      t.references :placement_drive, null: false, foreign_key: true
      t.references :student_profile, null: false, foreign_key: true
      t.string :status, null: false, default: "applied"
      t.datetime :applied_at, null: false
      t.timestamps
    end
    add_index :placement_applications, [:placement_drive_id, :student_profile_id], unique: true, name: "idx_unique_placement_application"

    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :body, null: false
      t.string :notification_type, null: false, default: "general"
      t.datetime :read_at
      t.references :notifiable, polymorphic: true
      t.timestamps
    end
    add_index :notifications, [:user_id, :read_at]

    create_table :documents do |t|
      t.string :title, null: false
      t.string :category, null: false
      t.text :description
      t.references :uploaded_by, null: false, foreign_key: { to_table: :users }
      t.string :visibility, null: false, default: "everyone"
      t.timestamps
    end

    create_table :activities do |t|
      t.references :user, foreign_key: true
      t.string :action, null: false
      t.text :description, null: false
      t.references :trackable, polymorphic: true
      t.timestamps
    end
  end
end
