Rails.application.routes.draw do
  # Support for original VIVO URLs
  get 'individual/:id/:id.:format' => 'individual#export', as: :individual_export
  get 'individual/:id' => 'individual#redirect'
  get 'display/:id' => 'display#show', as: :display_show
  get 'display/' => 'display#index'

  # Visualizations for faculty
  get 'display/:id/viz/coauthor' => 'visualization#coauthor', as: :visualization_coauthor
  get 'display/:id/viz/chord' => 'visualization#chord', as: :visualization_chord
  get 'display/:id/viz/coauthor2' => 'visualization#coauthor2', as: :visualization_coauthor2
  get 'display/:id/viz' => 'visualization#home', as: :visualization_home

  get 'search_facets' => 'search#facets'
  get 'search/advanced' => 'search#advanced', as: :search_advanced
  get 'search' => 'search#index', as: :search

  if ENV["FUSEKI_URL"] != nil
    get 'sparql/query' => 'sparql#query'
  end

  # Forwards call to viz data service (used to bypass same-origin
  # check when testing in dev with production services)
  get 'visualization/forward/forceEdgeGraph/:id' => 'visualization#fwd_force_one'
  get 'visualization/forward/forceEdgeGraph/' => 'visualization#fwd_force_list'
  get 'visualization/forward/chordDiagram/:id' => 'visualization#fwd_chord_one'
  get 'visualization/forward/chordDiagram/' => 'visualization#fwd_chord_list'

  # Returns hard-coded responses for testing offline
  get 'visualizations/fake/forceEdgeGraph/:id' => 'visualization#fake_force_one'
  # get 'visualizations/fake/forceEdgeGraph/' => 'visualization#fake_force_list'
  get 'visualizations/fake/chordDiagram/:id' => 'visualization#fake_chord_one'
  get 'visualizations/fake/chordDiagram/' => 'visualization#fake_chord_list'

  # VIVO original URLs
  get 'people' => 'home#people'
  get 'ous' => 'home#organizations'
  get 'file/:id/:file_name' => 'display#old_image'

  get 'brown' => 'home#brown', as: :home_brown
  get 'about' => 'home#about', as: :home_about
  get 'faq' => 'home#faq', as: :home_faq
  get 'help' => 'home#help', as: :home_help
  get 'history' => 'home#history', as: :home_history
  get 'publications' => 'home#publications', as: :home_publications
  get 'roadmap' => 'home#roadmap', as: :home_roadmap
  get 'termsOfUse' => 'home#termsofuse', as: :home_terms
  get 'status' => 'home#status'

  root 'home#index'

  get '*path' => 'home#page_not_found'
end
