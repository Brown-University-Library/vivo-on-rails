class DefaultPresenter
  attr_accessor :query, :form_values, :user, :edit_mode

  def initialize()
    @query = ""
    @form_values = []
    @user = nil       # User model
  end

  def can_edit?
    return false
  end
end
