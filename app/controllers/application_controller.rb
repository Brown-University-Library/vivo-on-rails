class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def must_be_authenticated()
    if !shibb_user?
      Rails.logger.error("No shibboleth information received")
      # TODO: redirect to a more specific page (depending on the request)
      redirect_to "/"
      return
    end
  end

  def shibb_user?
    if Rails.env.production?
      (request.env["Shibboleth-eppn"] != nil && request.env["Shibboleth-eppn"].strip != "")
    else
      # fake it
      true
    end
  end

  def shibb_eppn
    if Rails.env.production?
      request.env["Shibboleth-eppn"]
    else
      "jane.carberry"
    end
  end

  def shibb_fullname
    if Rails.env.production?
      request.env["Shibboleth-displayName"]
    else
      "Jane Carberry"
    end
  end
end
