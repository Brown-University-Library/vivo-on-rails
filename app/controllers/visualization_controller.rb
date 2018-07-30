class VisualizationController < ApplicationController
  def home
    redirect_to visualization_collab_path
  end

  def chord
    case params["format"]
    when "json"
      chord_json()
    else
      chord_view()
    end
  end

  def coauthor
    case params["format"]
    when "json"
      coauthor_json()
    when "csv"
      coauthor_csv()
    else
      coauthor_view("coauthor")
    end
  end

  def coauthor_treemap
    case params["format"]
    when "json"
      coauthor_json()
    when "csv"
      coauthor_csv()
    else
      coauthor_view("coauthor_treemap")
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

  def publications
    case params["format"]
    when "json"
      publications_json()
    when "csv"
      publications_csv()
    else
      publications_view()
    end
  end

  def coauthor_graph_list
    status = 200
    if ENV['VIZ_SERVICE_URL']
      # Returns the list of researchers that have a coauthor graph.
      # For now we let the client decide whether it should show the graph based
      # on the response.
      url = "#{ENV['VIZ_SERVICE_URL']}/coauthors/"
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

  private
    def chord_view
      id = params["id"]
      faculty = Faculty.load_from_solr(id)
      if faculty == nil
        err_msg = "Individual ID (#{id}) was not found"
        Rails.logger.warn(err_msg)
        render "not_found", status: 404, formats: [:html]
      else
        @presenter = FacultyPresenter.new(faculty.item, search_url(), nil, false)
        render "chord"
      end
    rescue => ex
      backtrace = ex.backtrace.join("\r\n")
      Rails.logger.error("Could not render #{name} visualization for #{id}. Exception: #{ex} \r\n #{backtrace}")
      render "error", status: 500
    end

    def chord_json
      status = 200
      id = "#{params[:id]}"
      url = "#{ENV['VIZ_SERVICE_URL']}/chordDiagram/#{id}"
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

    def coauthor_view(view_name)
      id = params["id"]
      faculty = Faculty.load_from_solr(id)
      if faculty == nil
        err_msg = "Individual ID (#{id}) was not found"
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

    def coauthor_json
      status = 200
      id = "#{params[:id]}"
      url = "#{ENV['VIZ_SERVICE_URL']}/coauthors/#{id}?ds=graph"
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
      url = "#{ENV['VIZ_SERVICE_URL']}/coauthors/#{id}?ds=graph"
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
        url = "#{ENV['VIZ_SERVICE_URL']}/collaborators/#{id}"
        ok, str = fwd_http(url)
        if ok
          json = JSON.parse(str)
        else
          Rails.logger.error("Could not retrieve graph at #{url}")
          status = 500
          json = {error: true, message: "Could not retrieve graph for #{id}"}
        end
        render json: json
      when "ORGANIZATION"
        # TODO: Update to use the visualization service when this data becomes available.
        id = params[:id]
        org = Organization.load_from_solr(id)
        collab = CollabGraph.new()
        graph = collab.graph_for_org(id, org.item.name)
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
        # TODO: Use viz service and convert to CSV
        collab = CollabGraph.new()
        graph = collab.graph_for(id)
        render text: graph.to_csv()
      when "ORGANIZATION"
        id = params[:id]
        org = Organization.load_from_solr(id)
        collab = CollabGraph.new()
        graph = collab.graph_for_org(id, org.item.name)
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

    def publications_csv
      id = params["id"]
      type = ModelUtils.type_for_id(id)
      case type
      when "PEOPLE"
        render text: "Not available"
      when "ORGANIZATION"
        id = params[:id]
        org = Organization.load_from_solr(id)
        matrix, years, columns = PublicationHistory.matrix_for_org(id)
        text = []
        # TODO: Include faculty headers
        # Move this to PublicationHistory
        matrix.each do |row|
          line = []
          row.keys.each do |key|
            line << row[key]
          end
          text << line.join(",")
        end
        render text: text.join("\n")
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

    def publications_json
      id = params["id"]
      type = ModelUtils.type_for_id(id)
      case type
      when "PEOPLE"
        # TODO
      when "ORGANIZATION"
        id = params[:id]
        org = Organization.load_from_solr(id)
        matrix, years, columns = PublicationHistory.matrix_for_org(id)
        render json: {matrix: matrix, years: years, columns: columns}
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

    def publications_view
      id = params[:id]
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
end
