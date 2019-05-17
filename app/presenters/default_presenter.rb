class DefaultPresenter
  attr_accessor :query, :form_values

  def initialize(controller = nil)
    @query = ""
    @form_values = []
    @controller = controller
  end

  def user_fullname
    return nil if @controller == nil
    @controller.shibb_fullname
  end
end
