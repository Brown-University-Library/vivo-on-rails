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

  def current_user
    User.for_session(shibb_eppn, shibb_fullname)
  end

  def shibb_email
    if Rails.env.production?
      request.env["Shibboleth-mail"]
    else
      "jane_carberry@brown.edu"
    end
  end

  def shibb_eppn
    if Rails.env.production?
      request.env["Shibboleth-eppn"]
    else
      "jcarberry@brown.edu"
    end
  end

  def shibb_fullname
    if Rails.env.production?
      request.env["Shibboleth-displayName"]
    else
      "Jane Carberry"
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
end
