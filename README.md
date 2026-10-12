# Campus AI Command Center

Campus AI Command Center is a full-stack Ruby on Rails campus operations application for students, faculty members, department administrators, and super administrators. It combines academics, attendance, assignments, projects, events, placements, helpdesk requests, documents, notifications, search, analytics, and a role-aware AI assistant in one server-rendered application.

The project is designed as a presentation-ready demonstration and as an understandable Rails codebase for computer science students. It uses conventional MVC, service objects for important business rules, server-side authorization, Hotwire, Active Storage, Active Job, and a versioned JSON API.

## Contents

- [Technology stack](#technology-stack)
- [Requirements](#requirements)
- [Quick start](#quick-start)
- [Demo accounts](#demo-accounts)
- [Application modules](#application-modules)
- [Roles and authorization](#roles-and-authorization)
- [Architecture](#architecture)
- [Database design](#database-design)
- [Important workflows](#important-workflows)
- [Campus AI](#campus-ai)
- [JSON API](#json-api)
- [Background jobs and email](#background-jobs-and-email)
- [Files and uploads](#files-and-uploads)
- [Seed data](#seed-data)
- [Testing and quality checks](#testing-and-quality-checks)
- [Environment variables](#environment-variables)
- [Production checklist](#production-checklist)
- [Troubleshooting](#troubleshooting)

## Technology stack

| Area | Implementation |
| --- | --- |
| Language | Ruby 4.0.5 |
| Framework | Ruby on Rails 8.0.5.1 |
| Database | SQLite 3 for development, test, and the included production template |
| Web server | Puma |
| Frontend | ERB, Hotwire/Turbo, Stimulus, Importmap, Propshaft, plain CSS |
| Authentication | Rails sessions and `has_secure_password`/bcrypt |
| File storage | Active Storage using local disk in development |
| Jobs | Active Job; Solid Queue is configured for production |
| Cache and cable | Solid Cache and Solid Cable are configured for production |
| Testing | Rails Minitest, Capybara, and Selenium support |
| Code quality | RuboCop Rails Omakase and Brakeman |
| Deployment | Puma/Thruster runtime; Kamal dependency available for future deployment setup |

The application uses Rails Importmap, so Node.js is not required for normal local setup. Redis is also not required because the production configuration uses Rails' database-backed Solid components.

## Requirements

Install the following before starting:

- Ruby `4.0.5` (the required version is recorded in `.ruby-version`)
- Bundler `4.x`
- SQLite 3
- Git

Optional tools:

- PostgreSQL, if the project is migrated away from SQLite for production
- ImageMagick or libvips, only if image variants are added later
- Chrome/Chromium and a compatible driver, only for browser system tests

Check the local environment with:

```bash
ruby --version
bundle --version
sqlite3 --version
```

## Quick start

Clone the repository and enter the application directory:

```bash
git clone <repository-url>
cd Campus-AI
```

Install dependencies and prepare the database:

```bash
bundle install
bin/rails db:prepare
bin/rails db:seed
```

`db:prepare` creates the database when necessary and runs all pending migrations. To use the individual commands instead:

```bash
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
```

Start the application:

```bash
bin/dev
```

The current `bin/dev` script starts the Rails server. This equivalent command also works:

```bash
bin/rails server
```

Open [http://localhost:3000](http://localhost:3000).

Health check endpoint: [http://localhost:3000/up](http://localhost:3000/up).

### Resetting demo data

The seed file rebuilds application demonstration records. On a development machine where discarding the local database is intentional, run:

```bash
bin/rails db:drop db:create db:migrate db:seed
```

Do not run the destructive reset command against a database containing information that must be retained.

## Demo accounts

All demo users have the password `password123`.

| Role | Email | Password | Main capabilities |
| --- | --- | --- | --- |
| Student | `student@example.com` | `password123` | View enrolled courses, mark attendance, submit assignments, register for events, apply for placements, raise helpdesk tickets, and use Campus AI |
| Faculty | `faculty@example.com` | `password123` | Manage assigned courses, class sessions, attendance sessions, and assignments; review academic information and projects |
| Department admin | `admin@example.com` | `password123` | View administration analytics, manage users and departments, update helpdesk tickets, upload documents, and access aggregate AI answers |
| Super admin | `superadmin@example.com` | `password123` | System-wide administration, including permitted role changes |

These credentials are development/demo data only. Change or remove them before any real deployment.

## Application modules

The authenticated sidebar provides access to all primary modules:

1. **Dashboard** — role-specific metrics, today's activity, deadlines, opportunities, and campus activity.
2. **Courses** — enrolled courses for students, assigned courses for faculty, and all courses for administrators.
3. **Attendance** — class-session management for faculty/admin users and course-scoped attendance information for students. Open sessions generate unique, time-limited attendance URLs.
4. **Assignments** — published assignment lists, faculty create/edit actions, student uploads, submission state, marks, and feedback.
5. **Projects** — student teams, faculty mentors, milestones, submissions, and reviews.
6. **Events** — upcoming published events, remaining capacity, registered participants, student registration, and cancellation.
7. **Placements** — companies, active drives, eligibility evaluation, readable pass/fail reasons, applications, and withdrawal.
8. **Helpdesk** — student complaints, categories, priorities, status tracking, comments, assignment to staff, activity records, and user notifications.
9. **Documents** — visibility-controlled campus resources, metadata search, and administrator uploads through Active Storage.
10. **Notifications** — unread badge, recent notification list, mark-one-read, and mark-all-read actions.
11. **Campus AI** — a ChatGPT-style, role-aware campus assistant with suggested prompts and recent conversation history.
12. **Profile** — the signed-in user's identity, role, department, and student/faculty details.

The top bar also contains global search, a notification shortcut, and sign out. Administrators receive a separate administration section for overview analytics, departments, and users.

### Global search

`GET /search?q=...` performs authorized, case-insensitive database search and groups useful campus results. `SearchService` owns the search logic so it can later be replaced by PostgreSQL full-text search without expanding the controller.

### Activity feed

Important events create `Activity` records, including attendance marking, assignment creation, helpdesk creation/status changes, project progress, event publication, and placement openings. Dashboards select activity appropriate to the signed-in role.

## Roles and authorization

`User.role` is a Rails enum with four values:

- `student`
- `faculty`
- `department_admin`
- `super_admin`

Authentication is required by `ApplicationController`. Authorization is enforced on the server; hiding a link is never treated as a security boundary.

| Capability | Student | Faculty | Department admin | Super admin |
| --- | :---: | :---: | :---: | :---: |
| View personal dashboard/profile | Yes | Yes | Yes | Yes |
| View scoped courses and assignments | Yes | Yes | Yes | Yes |
| Create class sessions and attendance links | No | Own courses | Yes | Yes |
| Create/edit assignments | No | Own assignments | Yes | Yes |
| Submit assignment work | Own work | No | No | No |
| View projects | Own teams | All | All | All |
| Register for events | Yes | No | No | No |
| Apply for placement drives | If eligible | No | No | No |
| Create helpdesk tickets | Yes | No | No | No |
| Update/assign helpdesk tickets | No | No | Yes | Yes |
| Upload documents | No | No | Yes | Yes |
| Manage departments/users | No | No | Yes | Yes |
| Change a user's role | No | No | No | Yes |

Examples of authorization boundaries:

- Student course and assignment queries are restricted to active enrollments.
- Students can read and change only their own assignment submissions.
- A student cannot view another user's helpdesk ticket or notification.
- Faculty class sessions and assignments are scoped to their faculty profile.
- Document visibility is evaluated for the current role.
- Admin controllers run behind `require_admin!`.
- Only a super administrator can change another user's role.

## Architecture

### Request flow

```text
Browser request
    -> Rails router
    -> controller authentication and authorization
    -> Active Record scope or domain service
    -> ERB/Turbo HTML or JSON response
```

### Main directories

| Directory | Responsibility |
| --- | --- |
| `app/models` | Active Record associations, validations, enums, scopes, and small domain helpers |
| `app/controllers` | Authentication, authorization, scoped loading, service orchestration, and responses |
| `app/controllers/admin` | Department and user administration plus aggregate overview |
| `app/controllers/api/v1` | Versioned, session-authenticated JSON endpoints |
| `app/views` | Accessible server-rendered ERB pages enhanced by Turbo |
| `app/services` | Testable business workflows and provider abstractions |
| `app/jobs` | Deferred reminder and email work |
| `app/mailers` | Welcome and campus notification email boundaries |
| `app/policies` | Base policy structure for future policy-specific authorization |
| `db/migrate` | Schema changes and database constraints |
| `db/seeds.rb` | Repeatable presentation data and demo accounts |
| `test` | Minitest integration, model, and service coverage |

### Service objects

- `AttendanceMarker` verifies the attendance token, time window, session state, enrollment, and duplicate attendance before creating a record.
- `EventRegistrationService` checks publication/deadline state and locks the event row so concurrent registrations cannot exceed capacity.
- `PlacementEligibilityChecker` evaluates deadline, drive status, CGPA, active backlogs, department, and graduation year, returning a boolean and structured explanations.
- `DashboardStatistics` assembles role-aware dashboard metrics outside controllers.
- `NotificationCreator` centralizes notification creation.
- `SearchService` performs scoped cross-module search.
- `Ai::AssistantService` chooses the configured AI provider.

### Hotwire and frontend

The UI is server-rendered and uses Turbo Drive, Turbo-compatible forms, Stimulus/Importmap support, Propshaft assets, and responsive plain CSS. No separate React application or Node build process is required.

## Database design

### Identity and academics

```text
User
  |-- StudentProfile -- Department
  |       |-- Enrollment -- Course -- FacultyProfile -- User
  |       |-- Attendance -- ClassSession -- Course
  |       `-- Submission -- Assignment -- Course
  `-- FacultyProfile -- Department
```

### Campus workflows

```text
Project
  |-- ProjectMembership -- StudentProfile
  |-- ProjectMilestone
  |-- ProjectSubmission
  `-- ProjectReview -- FacultyProfile

Event -- EventRegistration -- StudentProfile

Complaint -- ComplaintComment -- User

Company -- PlacementDrive
              |-- PlacementDriveDepartment -- Department
              `-- PlacementApplication -- StudentProfile

User
  |-- Notification -- optional polymorphic notifiable
  |-- Activity -- optional polymorphic trackable
  `-- uploaded Documents
```

The schema includes database indexes and uniqueness constraints for important invariants such as:

- normalized user email
- department and course code
- student roll number and faculty employee ID
- course enrollment per academic year
- attendance per student/session
- assignment submission per student/assignment
- project membership
- event registration
- placement application
- placement-drive department eligibility

Active Storage manages file attachment tables separately.

### Database portability

SQLite is used because it keeps the demonstration self-contained. The models and queries avoid intentional SQLite-only business logic. For a multi-process production deployment, use PostgreSQL and update `Gemfile` plus `config/database.yml`, then test migrations and case-insensitive searches before deployment.

## Important workflows

### Attendance

1. Faculty/admin creates a class session.
2. Opening attendance generates a cryptographically random URL-safe token valid for 20 minutes.
3. A student follows the attendance URL.
4. `AttendanceMarker` checks that the token matches, the session is open, it has not expired, and the student is enrolled.
5. A unique database constraint prevents a second attendance record for the same student/session.
6. The faculty session page displays the attendance list and count.

The URL is QR-compatible. A graphical QR image is not required to use the workflow; a QR library can later encode the existing URL without changing the attendance service.

### Assignments and submissions

1. Faculty creates or publishes an assignment for one of their courses.
2. Enrolled students receive in-app notifications.
3. Students upload their work with Active Storage.
4. A student may update their existing submission before the deadline.
5. Late initial work is labelled `late`; duplicate records are prevented.
6. Stored marks and feedback are shown with the submission.

### Event registration

1. Students browse published future events.
2. The registration service validates the deadline and available capacity while holding a database lock.
3. Registration is created once per event/student.
4. Students may cancel an active registration.

### Placement applications

1. A student opens an active placement drive.
2. `PlacementEligibilityChecker` explains each eligibility decision.
3. Application creation re-runs the service on the server instead of trusting the browser.
4. Eligible students can apply once and later withdraw.

### Helpdesk

1. A student opens a categorized, prioritized campus complaint.
2. Administrators see the ticket and can assign it or change its status.
3. Authorized participants add comments.
4. Status changes create a student notification and campus activity entry.

## Campus AI

Campus AI is designed behind a provider abstraction and works without an API key.

```text
Question from chat UI
    -> AiAssistantController
    -> Ai::AssistantService
    -> configured provider
    -> role-scoped Active Record data
    -> grounded response
```

### Demo provider

`Ai::DemoProvider` performs deterministic intent matching and answers from authorized application records. Supported topics include:

- today's classes
- attendance and attendance risk
- due assignments and academic overview
- placement eligibility and reasons
- projects and review work
- upcoming events
- notifications
- open complaints and helpdesk status
- administrator aggregate questions

The assistant page includes role-specific suggested questions, a limited recent conversation stored in the encrypted Rails session, and a clear-chat action.

### External provider

`Ai::ExternalProvider` is intentionally an extension point, not a completed network integration. If `AI_PROVIDER=external` is selected without `OPENAI_API_KEY`, it safely falls back to the demo provider. Even when a key exists, the placeholder does not transmit campus data.

Before connecting a real LLM, an institution should implement:

- privacy and legal review
- explicit data minimization and role-scoped context construction
- secret storage in Rails credentials or environment variables
- request timeouts and provider error handling
- audit logging and retention policy
- prompt-injection defenses and output validation
- automated authorization tests proving that cross-user information is never exposed

Rails—not the LLM—must remain responsible for authentication, authorization, and database access.

## JSON API

The API is namespaced under `/api/v1` and currently reuses the signed-in browser session. Log in through the HTML session endpoint, retain the session cookie, and then request JSON.

| Method | Endpoint | Description |
| --- | --- | --- |
| `GET` | `/api/v1/me` | Current user's public identity fields |
| `GET` | `/api/v1/courses` | Courses scoped to the current role |
| `GET` | `/api/v1/assignments` | Published assignments scoped to student enrollment or faculty ownership |
| `GET` | `/api/v1/events` | Upcoming published events |
| `GET` | `/api/v1/placement_drives` | Active placement drives |
| `GET` | `/api/v1/notifications` | Current user's latest notifications |
| `GET` | `/api/v1/attendance` | Current student's attendance records; student role required |

Example after authenticating and saving the Rails session cookie:

```bash
curl --cookie cookie.txt http://localhost:3000/api/v1/me
```

For mobile or third-party clients, add a dedicated revocable token or OAuth mechanism instead of sharing browser session cookies.

## Background jobs and email

`DeadlineReminderJob` finds published assignments due within 24 hours, skips students who already submitted, creates an in-app notification, and enqueues `NotificationEmailJob`.

`CampusMailer` defines messages for:

- welcome
- assignment deadline reminder
- event registration confirmation
- complaint status update
- placement application update

Run the reminder immediately in development:

```bash
bin/rails runner 'DeadlineReminderJob.perform_now'
```

Production uses Solid Queue. Start a worker using the deployment/process setup appropriate to the host; the Rails-provided command is:

```bash
bin/jobs
```

Development does not require real SMTP credentials. Configure an approved provider and `action_mailer` delivery settings before production email delivery.

## Files and uploads

Active Storage is used for assignment work, project-related attachments, and uploaded documents. Development stores files under `storage/`, which is intentionally ignored by Git.

For production:

- configure an object-storage service in `config/storage.yml`
- store credentials outside source control
- add content-type and size validation appropriate to policy
- scan untrusted uploads for malware
- define retention and deletion rules
- use private/signed delivery where records are not public

## Seed data

`bin/rails db:seed` creates a realistic fictional Indian college demonstration containing:

- 3 departments
- 24 students
- 6 faculty members plus an administrator faculty profile
- 1 department administrator and 1 super administrator
- 6 courses and enrollments
- current and historical class sessions with attendance records
- 8 assignments with sample submissions and grades
- 4 projects with teams, milestones, and reviews
- 6 published events with registrations
- 10 helpdesk complaints across multiple categories and statuses
- 5 companies and 5 placement drives with normalized department rules
- placement applications
- 6 document metadata records
- notifications and activity feed entries

All people and records are fictional. The seed prints the four main login credentials after completion.

## Testing and quality checks

Run the full automated test suite:

```bash
bin/rails test
```

Run framework and route checks:

```bash
bin/rails zeitwerk:check
bin/rails routes
```

Run linting and security analysis:

```bash
bin/rubocop
bin/brakeman --no-pager
```

Prepare and test the test database explicitly when needed:

```bash
RAILS_ENV=test bin/rails db:prepare
bin/rails test
```

The automated suite covers secure password handling, authentication, admin authorization, navigation visibility, session-authenticated API output, Campus AI conversation behavior, attendance expiry/duplication, event capacity, and placement eligibility explanations.

## Environment variables

No environment variable is required for the default local demonstration.

| Variable | Default | Purpose |
| --- | --- | --- |
| `AI_PROVIDER` | `demo` | Selects `demo` or the `external` placeholder provider |
| `OPENAI_API_KEY` | unset | Reserved for a future institution-approved external provider integration |
| `RAILS_ENV` | `development` | Selects Rails environment |
| `RAILS_LOG_LEVEL` | `info` in production | Controls production log verbosity |
| `RAILS_MAX_THREADS` | `5` | Database connection pool/thread setting |
| `JOB_CONCURRENCY` | `1` | Solid Queue production worker process count |
| `RAILS_MASTER_KEY` | unset locally | Decrypts production credentials when supplied by the deployment environment |

Never commit `.env`, `config/master.key`, database files, uploads, or real credentials.

## Production checklist

Before deploying for real users:

1. Replace all demo accounts and seed credentials.
2. Move from SQLite to PostgreSQL for concurrent/multi-process operation.
3. Configure `RAILS_MASTER_KEY`, `SECRET_KEY_BASE`, host authorization, and the production hostname.
4. Configure HTTPS, secure cookies, reverse proxy settings, and trusted origins.
5. Configure production object storage and private upload delivery.
6. Configure SMTP or another approved email provider.
7. Run the web service and Solid Queue worker as separate managed processes.
8. Establish database and file backups and test restoration.
9. Add monitoring, exception reporting, audit logs, and operational alerts.
10. Add pagination for lists expected to exceed demonstration size.
11. Add upload validation, malware scanning, retention, and privacy policies.
12. Perform accessibility, load, security, and authorization testing.
13. Implement a reviewed API token/OAuth design if non-browser API clients are required.
14. Complete institutional review before enabling any external AI data transfer.
15. Upgrade Rails through a tested release process as framework support windows change.

Deployment configuration is environment-specific and is intentionally not hardcoded. Add and review the required container image, Kamal, or platform configuration for the selected production host.

## Demonstration walkthrough

1. Sign in as `student@example.com` and show the dashboard, full sidebar, courses, attendance, assignments, events, placement eligibility, helpdesk, documents, notifications, profile, and Campus AI.
2. Ask Campus AI: `What placement drives am I eligible for?` The answer is calculated from seeded student and placement records.
3. Create a helpdesk ticket as the student. Sign in as `admin@example.com` in another browser session, assign the ticket, and move it to **In Progress**. Return to the student to show the status and notification.
4. Sign in as `faculty@example.com`, create or open a class session, open attendance, and copy the generated attendance URL. Follow it while signed in as an enrolled student and mark attendance.
5. Open a project to demonstrate its team, milestones, mentor, and review.
6. Open a placement drive to demonstrate the structured pass/fail eligibility reasons and protected application action.
7. Show an API response such as `/api/v1/me` while the user session is authenticated.

## Troubleshooting

### `bundle install` fails

Confirm Ruby `4.0.5` is active and install the Bundler version expected by `Gemfile.lock`:

```bash
ruby --version
tail -n 3 Gemfile.lock
gem install bundler
bundle install
```

### Pending migrations

```bash
bin/rails db:prepare
```

### Database or seed data is missing

```bash
bin/rails db:prepare
bin/rails db:seed
```

### Port 3000 is already in use

Start Rails on another port:

```bash
bin/rails server -p 3001
```

Then open [http://localhost:3001](http://localhost:3001).

### Uploaded files are missing after cloning

The `storage/` directory is local runtime data and is not committed. Re-upload files or restore the configured storage backup.

### AI returns deterministic answers

That is expected. `AI_PROVIDER=demo` is the safe default. The external provider is deliberately a non-networking placeholder until an institution implements and approves it.

## Current scope

This repository is a complete educational/demo application, not a pre-approved production student-information system. Core workflows, authorization, seeded records, and the deterministic Campus AI provider are implemented. External LLM calls, production SSO, real SMTP, production object storage, graphical QR rendering, antivirus scanning, and production observability require deployment-specific implementation and review.
