class AdvancedSearchPresenter
  attr_accessor :query, :form_values, :user, :edit_mode
  attr_accessor :q, :fq, :title, :department, :name

  def initialize(params)
    @query = ""
    @form_values = []
    @q = params["q"] || ""
    @fq = params["fq"] || ""
    @title = params["title_t"] || ""
    @department = params["department_t"] || ""
    @name = params["nameText"] || ""
    @user = nil
  end

  def can_edit?
    return false
  end
end
