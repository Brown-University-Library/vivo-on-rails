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
    if request.env["Shibboleth-eppn"] == nil || request.env["Shibboleth-eppn"].strip == ""
      return false
    end
    true
  end

  def shibb_eppn
    request.env["Shibboleth-eppn"]
  end

  def shibb_firstname
    request.env["Shibboleth-givenName"]
  end

  def shibb_fullname
    request.env["Shibboleth-displayName"]
  end
end
