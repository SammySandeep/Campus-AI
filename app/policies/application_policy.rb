class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def manage? = user&.admin?
  def view? = user.present?
  def create? = user.present?
  def update? = manage?
  def destroy? = manage?
end
