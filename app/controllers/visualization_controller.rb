require "coauthor_graph"
require "collab_graph"
require "model_utils"

class VisualizationController < ApplicationController
  def home
    redirect_to visualization_collab_path
  end

  def coauthor
    id = params["id"]
    case params["format"]
    when "json"
      coauthor_json(id)
    when "csv"
      coauthor_csv(id)
    else
      coauthor_view(id, "coauthor")
    end
  end

  def coauthor_treemap
    id = params["id"]
    case params["format"]
    when "json"
      coauthor_json(id)
    when "csv"
      coauthor_csv(id)
    else
      coauthor_view(id, "coauthor_treemap")
    end
  end

  def collab
    id = params["id"]
    case params["format"]
    when "json"
      collab_json(id)
    when "csv"
      collab_csv(id)
    else
      collab_view(id)
    end
  end

  def publications
    id = params["id"]
    case params["format"]
    when "json"
      publications_json(id)
    when "csv"
      publications_csv(id)
    else
      publications_view(id)
    end
  end

  private
    def coauthor_view(id, view_name)
      faculty = Faculty.load_from_solr(id)
      if faculty == nil
        err_msg = "Faculty ID (#{id}) was not found"
        Rails.logger.warn(err_msg)
        render "not_found", status: 404, formats: [:html]
      else
        @presenter = FacultyPresenter.new(faculty.item, search_url(), nil, false)
        render view_name
      end
    rescue => ex
      backtrace = ex.backtrace.join("\r\n")
      Rails.logger.error("Could not render #{name} visualization for #{id}. Exception: #{ex} \r\n #{backtrace}")
      render "error", status: 500
    end

    def coauthor_json(id)
      ok, data = CoauthorGraph.get_data(id)
      if ok
        render json: data, status: 200
      else
        Rails.logger.error("#{data[:message]}")
        render text: data[:message], status: data[:status]
      end
    end

    def coauthor_csv(id)
      ok, data = CoauthorGraph.get_data_csv(id)
      if ok
        render text: data
      else
        Rails.logger.error("#{data[:message]}")
        render text: data[:message], status: data[:status]
      end
    end

    def collab_view(id)
      type = ModelUtils.type_for_id(id)
      case type
      when "PEOPLE"
        faculty = Faculty.load_from_solr(id)
        @presenter = FacultyPresenter.new(faculty.item, search_url(), nil, false)
        render "collab"
      when "ORGANIZATION"
        org = Organization.load_from_solr(id)
        @presenter = OrganizationPresenter.new(org.item, search_url(), nil, false)
        render "collab_org"
      else
        err_msg = "Individual ID (#{id}) was not found"
        Rails.logger.warn(err_msg)
        render "not_found", status: 404, formats: [:html]
      end
    rescue => ex
      backtrace = ex.backtrace.join("\r\n")
      Rails.logger.error("Could not render collaboration visualization for #{id}. Exception: #{ex} \r\n #{backtrace}")
      render "error", status: 500
    end

    def collab_json(id)
      ok, data = CollabGraph.get_data(id)
      if ok
        render json: data, status: 200
      else
        Rails.logger.error("#{data[:message]}")
        render text: data[:message], status: data[:status]
      end
    rescue => ex
      backtrace = ex.backtrace.join("\r\n")
      Rails.logger.error("Could not fetch collaboration data for #{id}. Exception: #{ex} \r\n #{backtrace}")
      render json: "error", status: 500
    end

    def collab_csv(id)
      ok, data = CollabGraph.get_data_csv(id)
      if ok
        render text: data
      else
        Rails.logger.error("#{data[:message]}")
        render text: data[:message], status: data[:status]
      end
    rescue => ex
      backtrace = ex.backtrace.join("\r\n")
      Rails.logger.error("Could not fetch collaboration data for #{id}. Exception: #{ex} \r\n #{backtrace}")
      render text: "error", status: 500
    end

    def publications_view(id)
      org = Organization.load_from_solr(id)
      if org == nil
        err_msg = "Organization ID (#{id}) was not found"
        Rails.logger.warn(err_msg)
        render "not_found", status: 404, formats: [:html]
      else
        @presenter = OrganizationPresenter.new(org.item, search_url(), nil, false)
        render "publications_org"
      end
    rescue => ex
      backtrace = ex.backtrace.join("\r\n")
      Rails.logger.error("Could not render publication visualization for #{id}. Exception: #{ex} \r\n #{backtrace}")
      render "error", status: 500
    end

    def publications_json(id)
      type = ModelUtils.type_for_id(id)
      case type
      when "PEOPLE"
        render json: {message: "Invalid request for this ID"}, status: 400
      when "ORGANIZATION"
        id = params[:id]
        treemap = PublicationHistory.treemap(id)
        render json: treemap
      else
        err_msg = "Individual ID (#{id}) was not found"
        Rails.logger.warn(err_msg)
        render json: [], status: 404
      end
    rescue => ex
      backtrace = ex.backtrace.join("\r\n")
      Rails.logger.error("Could not fetch publication timeline for #{id}. Exception: #{ex} \r\n #{backtrace}")
      render json: "error", status: 500
    end

    def publications_csv(id)
      type = ModelUtils.type_for_id(id)
      case type
      when "PEOPLE"
        render text: "Invalid request for this ID", status: 400
      when "ORGANIZATION"
        id = params[:id]
        csv = PublicationHistory.treemap_csv(id)
        render text: csv
      else
        err_msg = "Individual ID (#{id}) was not found"
        Rails.logger.warn(err_msg)
        render text: "", status: 404
      end
    rescue => ex
      backtrace = ex.backtrace.join("\r\n")
      Rails.logger.error("Could not fetch publication data for #{id}. Exception: #{ex} \r\n #{backtrace}")
      render text: "error", status: 500
    end
end
