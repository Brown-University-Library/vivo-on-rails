class DefaultPresenter
  attr_accessor :query, :form_values, :user

  def initialize()
    @query = ""
    @form_values = []
    @user = nil       # User model
  end
end
