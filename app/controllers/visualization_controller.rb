class VisualizationController < ApplicationController
  def chord
    render_viz("chord")
  end

  def coauthor
    render_viz("coauthor")
  end

  def collab
    render_viz("collab")
  end

  def home
    redirect_to visualization_coauthor_path
  end

  def fake_chord_list
    str = VisualizationFakeData.chord_list
    json = JSON.parse(str)
    render :json => json
  end

  def fake_chord_one
    str = VisualizationFakeData.chord_one
    json = JSON.parse(str)
    render :json => json
  end

  def fake_force_one
    str = VisualizationFakeData.force_one
    json = JSON.parse(str)
    render :json => json
  end

  def fwd_force_one
    url = "#{ENV['VIZ_SERVICE_URL']}/forceEdgeGraph/#{params[:id]}"
    str = fwd_http(url)
    render_json(str)
  end

  def collab_one
    id = params[:id]
    collab = CollabGraph.new()
    graph = collab.graph_for(id)
    render_json(graph.to_json)
  end

  def fwd_force_list
    url = "#{ENV['VIZ_SERVICE_URL']}/forceEdgeGraph/"
    str = fwd_http(url)
    render_json(str)
  end

  def fwd_chord_one
    url = "#{ENV['VIZ_SERVICE_URL']}/chordDiagram/#{params[:id]}"
    str = fwd_http(url)
    render_json(str)
  end

  def fwd_chord_list
    url = "#{ENV['VIZ_SERVICE_URL']}/chordDiagram/"
    str = fwd_http(url)
    render_json(str)
  end

  private
    def render_viz(name)
      id = params["id"]
      faculty = Faculty.load_from_solr(id)
      if faculty == nil
        err_msg = "Individual ID (#{id}) was not found"
        Rails.logger.warn(err_msg)
        render "not_found", status: 404, formats: [:html]
      else
        @presenter = FacultyPresenter.new(faculty.item, search_url(), nil, false)
        render name
      end
    rescue => ex
      backtrace = ex.backtrace.join("\r\n")
      Rails.logger.error("Could not render #{name} visualization for #{id}. Exception: #{ex} \r\n #{backtrace}")
      render "error", status: 500
    end

    def render_json(str)
      json = JSON.parse(str)
      render :json => json
    end

    def fwd_http(url)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      response.body
    end
end
