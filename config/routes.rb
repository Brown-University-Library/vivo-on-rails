Rails.application.routes.draw do
  # Support for original VIVO URLs
  get 'individual/:id/:id.:format' => 'individual#export', as: :individual_export
  get 'individual/:id' => 'individual#redirect'
  get 'display/:id/data/coauthor' => 'display#data_coauthor'
  get 'display/:id/viz' => 'display#visualizations', as: :display_visualizations
  get 'display/:id' => 'display#show', as: :display_show
  get 'display/' => 'display#index'

  get 'search_facets' => 'search#facets'
  get 'search/advanced' => 'search#advanced', as: :search_advanced
  get 'search' => 'search#index', as: :search

  if ENV["FUSEKI_URL"] != nil
    get 'sparql/query' => 'sparql#query'
  end

  # Forwards call to viz data service (used to bypass same-origin
  # check when testing in dev with production services)
  get 'visualizations/forward/forceEdgeGraph/:id' => 'visualization#fwd_force_one'
  get 'visualizations/forward/forceEdgeGraph/' => 'visualization#fwd_force_list'
  get 'visualizations/forward/chordDiagram/:id' => 'visualization#fwd_chord_one'
  get 'visualizations/forward/chordDiagram/' => 'visualization#fwd_chord_list'

  # Returns hard-coded response
  get 'visualizations/fake/force/:id' => 'visualization#fake_force_one'
  # get 'visualizations/fake/force/' => 'visualization#fake_force_list'
  get 'visualizations/fake/chord/:id' => 'visualization#fake_chord_one'
  get 'visualizations/fake/chord/' => 'visualization#fake_chord_list'

  # VIVO original URLs
  get 'people' => 'home#people'
  get 'ous' => 'home#organizations'
  get 'file/:id/:file_name' => 'display#old_image'

  get 'brown' => 'home#brown', as: :home_brown
  get 'about' => 'home#about', as: :home_about
  get 'faq' => 'home#faq', as: :home_faq
  get 'help' => 'home#help', as: :home_help
  get 'publications' => 'home#publications', as: :home_publications
  get 'roadmap' => 'home#roadmap', as: :home_roadmap
  get 'termsOfUse' => 'home#termsofuse', as: :home_terms
  get 'status' => 'home#status'

  root 'home#index'

  get '*path' => 'home#page_not_found'
end
