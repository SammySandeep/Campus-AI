# Campus AI Command Center

Campus AI Command Center is a production-minded, server-rendered Ruby on Rails demonstration application for students, faculty, department administrators, and super administrators. It brings academics, attendance, projects, campus events, helpdesk requests, placements, documents, notifications, search, and a safe demo AI assistant into one role-aware platform.

## Requirements

- Ruby 4.0.5
- Rails 8.0.5.1
- Bundler 4.x (the generated lockfile records the exact version used)
- SQLite 3 for local development and tests
- Node is not required: JavaScript is delivered with Rails Importmap
- Redis is not required: Rails database-backed Solid Queue, Solid Cache, and Solid Cable are configured
- ImageMagick/libvips are not required unless image variants are added later

The application uses SQLite locally because a PostgreSQL server was not running in the build environment. The schema and application queries avoid SQLite-specific features and can be moved to PostgreSQL by changing `config/database.yml` and the database gem.

## Installation

```bash
cd /Users/sammy_sandeep/Desktop/Campus-AI
bundle install
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
```

To reset to a clean, fully seeded demonstration database:

```bash
bin/rails db:drop db:create db:migrate db:seed
```

The seed is intentionally repeatable: it clears and rebuilds only application demo records.

## Starting the application

```bash
bin/rails server
```

Open [http://localhost:3000](http://localhost:3000). `bin/dev` is also available and currently launches the Rails server.

## Demo accounts

These credentials are development/demo-only. Never use them in production.

| Role | Email | Password |
| --- | --- | --- |
| Student | `student@example.com` | `password123` |
| Faculty | `faculty@example.com` | `password123` |
| Department admin | `admin@example.com` | `password123` |
| Super admin | `superadmin@example.com` | `password123` |

## Features

- Secure password authentication with Rails `has_secure_password`
- Server-side role and ownership authorization for students, faculty, department admins, and super admins
- Role-aware dashboards with live metrics and recent campus activity
- Departments, student/faculty profiles, courses, and academic-year enrollments
- Time-limited, unique attendance links with enrollment, expiry, and duplicate checks
- Assignments, Active Storage submission uploads, grading fields, and deadlines
- Student project teams, milestones, submissions, mentors, and faculty reviews
- Published campus events with capacity-safe registration and cancellation
- Campus helpdesk tickets, assignment, comments, status history, notifications, and filtering
- Placement companies, normalized department eligibility, readable criteria explanations, and applications
- Visibility-controlled documents with Active Storage uploads and metadata search
- Per-user notifications, unread counts, mark-one/mark-all actions, and activity feed
- Authorized global search across useful campus entities
- Deterministic, private demo AI answers from current application data
- Versioned session-authenticated JSON API under `/api/v1`
- Active Job reminder architecture, Action Mailer messages, and database-backed job readiness
- Responsive server-rendered UI with Turbo, Stimulus, Importmap, and plain CSS

## Architecture

The project follows conventional Rails MVC:

- `app/models`: Active Record associations, scopes, validations, and small domain helpers
- `app/controllers`: authentication, authorization, loading, orchestration, and responses
- `app/views`: accessible server-rendered HTML enhanced by Turbo
- `app/services`: business rules such as attendance marking, event registration, search, dashboard metrics, placement eligibility, and AI provider selection
- `app/jobs` and `app/mailers`: reminder and notification delivery boundaries
- `app/policies`: a lightweight base policy for future policy-specific expansion

Important service objects:

- `AttendanceMarker` validates token, expiry, enrollment, and duplicate attendance.
- `EventRegistrationService` locks the event row so concurrent registrations cannot exceed capacity.
- `PlacementEligibilityChecker` returns an eligibility boolean plus a structured reason for every criterion.
- `Ai::AssistantService` selects a provider. `DemoProvider` uses only authorized records; `ExternalProvider` is a safe extension point.
- `SearchService` centralizes scoped, case-insensitive database search so PostgreSQL full-text search can replace it later.

Database uniqueness constraints back up model validations for email, roll number, employee ID, course code, enrollment, attendance, submissions, event registration, project membership, placement applications, and drive departments.

## Database overview

Core identity and academics:

`User → StudentProfile/FacultyProfile → Department → Course → Enrollment`

Major workflows:

- `Course → ClassSession → Attendance`
- `Course → Assignment → Submission`
- `Project → ProjectMembership/ProjectMilestone/ProjectSubmission/ProjectReview`
- `Event → EventRegistration`
- `Complaint → ComplaintComment`
- `Company → PlacementDrive → PlacementDriveDepartment/PlacementApplication`
- `User → Notification/Document/Activity`

Uploaded assignment work, project files, and documents use Rails Active Storage.

## Running tests and checks

```bash
bin/rails test
bin/rails zeitwerk:check
bin/rails routes
bin/brakeman --no-pager
bin/rubocop
```

The automated suite covers authentication, admin authorization, session-authenticated API output, password handling, placement criteria, attendance expiry and duplicate prevention, and event capacity.

## JSON API

The first version intentionally reuses browser session authentication. Sign in through `/session`, retain the Rails session cookie, and request JSON from:

- `GET /api/v1/me`
- `GET /api/v1/courses`
- `GET /api/v1/assignments`
- `GET /api/v1/events`
- `GET /api/v1/placement_drives`
- `GET /api/v1/notifications`
- `GET /api/v1/attendance` (student accounts)

Responses are scoped through the same role and ownership rules as the HTML interface. A mobile/third-party client should add a dedicated revocable token or OAuth layer rather than sharing browser cookies.

## Background jobs and email

`DeadlineReminderJob` creates in-app notifications and enqueues `NotificationEmailJob`. Development email does not require SMTP credentials; Rails uses development-safe delivery behavior. Production should configure an approved mail provider and run Solid Queue workers.

Example manual reminder run:

```bash
bin/rails runner 'DeadlineReminderJob.perform_now'
```

## AI configuration

No AI key is required. The default deterministic provider supports questions about classes, attendance, assignments, placement eligibility, events, and complaints.

Optional environment variables:

```text
AI_PROVIDER=demo
OPENAI_API_KEY=
```

Setting `AI_PROVIDER=external` currently selects a documented placeholder that falls back safely when no key exists. It does not send student data to an external service. An institution must implement privacy review, consent, data minimization, audit logging, and an approved HTTP integration before enabling external AI.

## Demo walkthrough

1. Sign in as the student and show the dashboard, attendance, deadlines, events, placement eligibility, and AI answer for “What placement drives am I eligible for?”
2. Raise a helpdesk complaint. Sign in as the admin in a private browser window, assign it, and move it to In Progress.
3. Sign in as faculty, create/open a class session, copy its time-limited attendance URL, and use the student account to mark attendance.
4. Open a seeded project to show its team, milestones, and review.
5. Open a placement drive to show every passed/failed eligibility reason.

## Production notes

- Replace SQLite with PostgreSQL for multi-process production deployments.
- Use environment-backed Rails credentials and never commit secrets.
- Configure HTTPS, host authorization, SMTP, object storage, backups, monitoring, and a Solid Queue worker.
- Add upload content-type/size policies suited to institutional requirements and antivirus scanning before accepting untrusted production files.
- The generated Rails 8.0 line was selected because it is the installed version in the provided environment; plan a tested upgrade before its maintenance window ends.
