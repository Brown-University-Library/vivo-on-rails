class ReportsPresenter
    attr_accessor :query, :form_values, :user, :edit_mode
    attr_accessor :reports

    def initialize(user, reports)
      @query = ""
      @form_values = []
      @user = user
      @reports = reports
    end

    def can_edit?
      return false
    end
  end
