require 'securerandom'
require "./app/models/book_cover.rb"
class HomeController < ApplicationController
  def about
    @presenter = DefaultPresenter.new()
  end

  def brown
    @presenter = DefaultPresenter.new()
  end

  # e.g. /side_stuff/brown_classic/Cherry_John.htm?_ijt=3br7bc50889e66bblosud6i95b
  def brown_classic
    q = ""
    if params[:name]
      q = params[:name].gsub("_", " ")
    end
    redirect_to "#{search_url(q: q)}"
  end

  def faq
    @presenter = DefaultPresenter.new()
  end

  def help
    @presenter = DefaultPresenter.new()
  end

  def help_viz
    @presenter = DefaultPresenter.new()
  end

  def history
    @presenter = DefaultPresenter.new()
  end

  def index
    if params[:alias] != nil
      # e.g. https://vivo.brown.edu/?alias=Nicole_Nugent
      q = params[:alias].to_s.gsub("_", " ")
      redirect_to "#{search_url()}?q=#{q}"
      return
    end

    if ENV["NOTICE_BANNER"]
        flash[:notice] = ENV["NOTICE_BANNER"]
    end

    page_size = 4
    base_author_url = display_show_url("")
    @bookCoversPaginated = BookCoverModel.get_all_paginated(base_author_url, page_size)
    @presenter = DefaultPresenter.new()
  end

  def publications
    @presenter = DefaultPresenter.new()
  end

  def roadmap
    @presenter = DefaultPresenter.new()
  end

  def termsofuse
    @presenter = DefaultPresenter.new()
  end

  def page_not_found
    # Use the page title to track page not found in Google Analytics
    # (see https://www.practicalecommerce.com/Locating-404s-with-Google-Analytics)
    @page_title = "Page not found"
    err_msg = "Page #{request.url} was not found"
    Rails.logger.warn(err_msg)
    # Force to render as HTML
    render "not_found", status: 404, formats: [:html]
  end

  # Redirect to new facetted search
  def people
    redirect_to "#{search_url()}?fq=record_type|PEOPLE"
  end

  # Redirect to new facetted search
  def organizations
    redirect_to "#{search_url()}?fq=record_type|ORGANIZATION"
  end

  def status
    solr_url = ENV["SOLR_URL"]
    searcher = Search.new(solr_url, nil)
    params = SolrLite::SearchParams.new
    search_results = searcher.search(params)
    if search_results.num_found > 0
      render :json => {status: "OK", message: "#{search_results.num_found} records found."}
    else
      error_id = SecureRandom.uuid
      Rails.logger.error("Error checking status (#{error_id}). No search results were found.")
      render :json => {status: "ERROR", message: "No search results were found (#{error_id})"}, status: 500
    end
  rescue => ex
    error_id = SecureRandom.uuid
    backtrace = ex.backtrace.join("\r\n")
    Rails.logger.error("Error checking status (#{error_id}). Exception: #{ex} \r\n #{backtrace}")
    render :json => {status: "ERROR", message: "Exception was found. See the log file (#{error_id})."}, status: 500
  end
end
