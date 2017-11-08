require 'securerandom'
require "./app/models/book_cover.rb"
class HomeController < ApplicationController
  def about
  end

  def brown
  end

  def faq
  end

  def help
  end

  def index
    page_size = 4
    base_author_url = display_show_url("")
    @bookCoversPaginated = BookCoverModel.get_all_paginated(base_author_url, page_size)
  end

  def publications
  end

  def roadmap
  end

  def termsofuse
  end

  def page_not_found
    err_msg = "Page #{request.url} was not found"
    Rails.logger.warn(err_msg)
    # Force to render as HTML
    render "not_found", status: 404, formats: [:html]
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
