require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "normalizes email and authenticates securely" do
    user = User.create!(email: "  PERSON@EXAMPLE.COM ", password: "password123", first_name: "A", last_name: "Person", role: :student)
    assert_equal "person@example.com", user.email
    assert user.authenticate("password123")
    assert_not user.authenticate("wrong")
  end

  test "requires a unique email" do
    User.create!(email: "unique@example.com", password: "password123", first_name: "A", last_name: "One")
    duplicate = User.new(email: "UNIQUE@example.com", password: "password123", first_name: "B", last_name: "Two")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], "has already been taken"
  end
end
