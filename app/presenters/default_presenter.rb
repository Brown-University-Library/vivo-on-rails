class DefaultPresenter
  attr_accessor :query, :form_values

  def initialize()
    @query = ""
    @form_values = []
  end
end
