class VisualizationController < ApplicationController
  def home
    redirect_to visualization_collab_path
  end

  # def chord
  #   id = params["id"]
  #   faculty = Faculty.load_from_solr(id)
  #   if faculty == nil
  #     err_msg = "Individual ID (#{id}) was not found"
  #     Rails.logger.warn(err_msg)
  #     render "not_found", status: 404, formats: [:html]
  #   else
  #     @presenter = FacultyPresenter.new(faculty.item, search_url(), nil, false)
  #     render "chord"
  #   end
  # rescue => ex
  #   backtrace = ex.backtrace.join("\r\n")
  #   Rails.logger.error("Could not render #{name} visualization for #{id}. Exception: #{ex} \r\n #{backtrace}")
  #   render "error", status: 500
  # end

  def coauthor
    case params["format"]
    when "json"
      coauthor_json()
    when "csv"
      coauthor_csv()
    else
      coauthor_view()
    end
  end

  def collab
    case params["format"]
    when "json"
      collab_json()
    when "csv"
      collab_csv()
    else
      collab_view()
    end
  end

  def coauthor_graph_list
    status = 200
    if ENV['VIZ_SERVICE_URL']
      # Returns the list of researchers that have a coauthor graph.
      # For now we let the client decide whether it should show the graph based
      # on the response.
      url = "#{ENV['VIZ_SERVICE_URL']}/forceEdgeGraph/"
      ok, str = fwd_http(url)
      if ok
        json = JSON.parse(str)
      else
        Rails.logger.error("Could not retrieve graph at #{url}")
        status = 500
        json = {error: true, message: "Could not retrieve graph data"}
      end
    else
      json = {}
    end
    render json: json, status: status
  end

  # def fwd_chord_one
  #   url = "#{ENV['VIZ_SERVICE_URL']}/chordDiagram/#{params[:id]}"
  #   str = fwd_http(url)
  #   render_json(str)
  # end
  #
  # def fake_chord_one
  #   str = VisualizationFakeData.chord_one
  #   json = JSON.parse(str)
  #   render :json => json
  # end
  #
  # def fake_force_one
  #   str = VisualizationFakeData.force_one
  #   json = JSON.parse(str)
  #   render :json => json
  # end

  private
    def coauthor_view
      id = params["id"]
      faculty = Faculty.load_from_solr(id)
      if faculty == nil
        err_msg = "Individual ID (#{id}) was not found"
        Rails.logger.warn(err_msg)
        render "not_found", status: 404, formats: [:html]
      else
        @presenter = FacultyPresenter.new(faculty.item, search_url(), nil, false)
        render "coauthor"
      end
    rescue => ex
      backtrace = ex.backtrace.join("\r\n")
      Rails.logger.error("Could not render #{name} visualization for #{id}. Exception: #{ex} \r\n #{backtrace}")
      render "error", status: 500
    end

    def coauthor_json
      status = 200
      id = "#{params[:id]}"
      url = "#{ENV['VIZ_SERVICE_URL']}/forceEdgeGraph/#{id}"
      ok, str = fwd_http(url)
      if ok
        json = JSON.parse(str)
      else
        Rails.logger.error("Could not retrieve graph at #{url}")
        status = 500
        json = {error: true, message: "Could not retrieve graph for #{id}"}
      end
      render json: json, status: status
    end

    def coauthor_csv
      # get the JSON version
      id = "#{params[:id]}"
      url = "#{ENV['VIZ_SERVICE_URL']}/forceEdgeGraph/#{id}"
      ok, str = fwd_http(url)
      if ok
        # dump it to an EdgeGraph in order to produce the CSV output
        json = JSON.parse(str, {symbolize_names: true})
        graph = EdgeGraph.new_from_hash(json)
        render text: graph.to_csv()
      else
        render text: "Could not fetch graph for #{id}", status: 500
      end
    end

    def collab_view
      id = params["id"]
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

    def collab_json
      id = params["id"]
      type = ModelUtils.type_for_id(id)
      case type
      when "PEOPLE"
        collab = CollabGraph.new()
        graph = collab.graph_for(id)
        render json: graph
      when "ORGANIZATION"
        id = params[:id]
        collab = CollabGraph.new()
        graph = collab.graph_for_org(id)
        render json: graph
      else
        err_msg = "Individual ID (#{id}) was not found"
        Rails.logger.warn(err_msg)
        render json: [], status: 404
      end
    rescue => ex
      backtrace = ex.backtrace.join("\r\n")
      Rails.logger.error("Could not fetc collaboration data for #{id}. Exception: #{ex} \r\n #{backtrace}")
      render json: "error", status: 500
    end

    def collab_csv
      id = params["id"]
      type = ModelUtils.type_for_id(id)
      case type
      when "PEOPLE"
        collab = CollabGraph.new()
        graph = collab.graph_for(id)
        render text: graph.to_csv()
      when "ORGANIZATION"
        id = params[:id]
        collab = CollabGraph.new()
        graph = collab.graph_for_org(id)
        render text: graph.to_csv()
      else
        err_msg = "Individual ID (#{id}) was not found"
        Rails.logger.warn(err_msg)
        render text: "", status: 404
      end
    rescue => ex
      backtrace = ex.backtrace.join("\r\n")
      Rails.logger.error("Could not fetch collaboration data for #{id}. Exception: #{ex} \r\n #{backtrace}")
      render text: "error", status: 500
    end

    def fwd_http(url)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.open_timeout = 10
      http.read_timeout = 10
      http.ssl_timeout = 10
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      ok = (response.code >= "200" && response.code <= "299")
      [ok, response.body]
    rescue => ex
      Rails.logger.error("Fetching: #{url}. Exception: #{ex}")
      [false, ""]
    end
end
