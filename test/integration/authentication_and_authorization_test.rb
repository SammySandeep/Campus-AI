require "test_helper"

class AuthenticationAndAuthorizationTest < ActionDispatch::IntegrationTest
  test "requires authentication and signs a student in" do
    user, = student(email: "login@example.com")
    get dashboard_path
    assert_redirected_to login_path

    post session_path, params: { email: user.email, password: "password123" }
    assert_redirected_to dashboard_path
    follow_redirect!
    assert_response :success
    assert_includes response.body, user.first_name
  end

  test "student cannot access admin users" do
    user, = student
    post session_path, params: { email: user.email, password: "password123" }
    get admin_users_path
    assert_redirected_to dashboard_path
  end

  test "authenticated api exposes current user but not password" do
    user, = student
    post session_path, params: { email: user.email, password: "password123" }
    get api_v1_me_path, as: :json
    assert_response :success
    payload = response.parsed_body
    assert_equal user.email, payload["email"]
    assert_not payload.key?("password_digest")
  end

  test "assistant keeps a short role-aware conversation" do
    user, = student
    post session_path, params: { email: user.email, password: "password123" }

    post assistant_path, params: { question: "What can you help me with?" }
    assert_redirected_to assistant_path(anchor: "latest")
    follow_redirect!
    assert_response :success
    assert_includes response.body, "I can answer questions about"
    assert_includes response.body, "What can you help me with?"

    delete assistant_path
    assert_redirected_to assistant_path
  end

  test "authenticated navigation exposes every campus module" do
    user, = student
    post session_path, params: { email: user.email, password: "password123" }

    get dashboard_path
    assert_response :success

    {
      "Dashboard" => dashboard_path,
      "Courses" => courses_path,
      "Attendance" => class_sessions_path,
      "Assignments" => assignments_path,
      "Projects" => projects_path,
      "Events" => events_path,
      "Placements" => placement_drives_path,
      "Helpdesk" => complaints_path,
      "Documents" => documents_path,
      "Notifications" => notifications_path,
      "Campus AI" => assistant_path,
      "Profile" => profile_path
    }.each do |label, path|
      assert_select "nav a[href='#{path}']", text: /#{Regexp.escape(label)}/
    end
  end

  test "administrator navigation exposes management modules" do
    admin = User.create!(email: "navigation-admin@example.com", password: "password123", first_name: "Nav", last_name: "Admin", role: :department_admin)
    FacultyProfile.create!(user: admin, department: department, employee_id: "E#{SecureRandom.hex(4)}", designation: "Administrator")
    post session_path, params: { email: admin.email, password: "password123" }

    get admin_root_path
    assert_response :success
    assert_select "nav a[href='#{admin_root_path}']", text: /Admin overview/
    assert_select "nav a[href='#{admin_users_path}']", text: /User management/
    assert_select "nav a[href='#{admin_departments_path}']", text: /Departments/
  end
end
