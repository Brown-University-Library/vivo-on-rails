class ReportsPresenter
    attr_accessor :query, :form_values, :user, :reports

    def initialize(user, reports)
      @query = ""
      @form_values = []
      @user = user
      @reports = reports
    end
  end
