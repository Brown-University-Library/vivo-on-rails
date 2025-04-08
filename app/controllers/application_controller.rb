class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action { |controller| BotDetectController.bot_detection_enforce_filter(controller) }

  def must_be_authenticated(format = nil)
    if !shibb_user?
      if format == "json"
        raise "No shibboleth information received (JSON)"
      end
      # TODO: redirect to a more specific page (depending on the request)
      Rails.logger.error("No shibboleth information received")
      redirect_to "/"
    end
  end

  def current_user()
    if shibb_user?
      User.for_session(shibb_eppn, shibb_fullname)
    else
      nil
    end
  end

  def shibb_email()
    if Rails.env.production?
      request.env["Shibboleth-mail"]
    else
      "jane_carberry@brown.edu"
    end
  end

  def shibb_eppn()
    if Rails.env.production?
      request.env["Shibboleth-eppn"]
    else
      # fake it
      "jcarberry@brown.edu"
    end
  end

  def shibb_fullname()
    if Rails.env.production?
      request.env["Shibboleth-displayName"]
    else
      # fake it
      "Jane Carberry"
    end
  end

  def shibb_user?
    return shibb_eppn() != nil
  end

  def new_editor_request()
    if ENV["NEW_EDITOR"] == nil || ENV["NEW_EDITOR"] == "false"
      return false
    end

    # Always allowed
    if ENV["NEW_EDITOR"] == "true"
      return true
    end

    # Allowed if the request passed the correct value
    # (used while testing before full rollout)
    ENV["NEW_EDITOR"] == request.params["NEW_EDITOR"]
  end
end
