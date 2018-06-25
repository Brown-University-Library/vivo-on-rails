Rails.application.routes.draw do
  # Support for original VIVO URLs
  get 'individual/:id/:id.:format' => 'individual#export', as: :individual_export
  get 'individual/:id' => 'individual#redirect'
  get 'display/:id' => 'display#show', as: :display_show
  get 'display/' => 'display#index'


  # Visualizations for faculty (and organizations)
  get 'display/:id/viz/coauthor' => 'visualization#coauthor', as: :visualization_coauthor
  get 'display/:id/viz/chord' => 'visualization#chord', as: :visualization_chord
  get 'display/:id/viz/collab' => 'visualization#collab', as: :visualization_collab
  get 'display/:id/viz' => 'visualization#home', as: :visualization_home
  get 'viz/coauthorGraphList' => 'visualization#coauthor_graph_list', as: :visualization_coauthor_graph_list


  # Search URLs
  get 'search_facets' => 'search#facets'
  get 'search/advanced' => 'search#advanced', as: :search_advanced
  get 'search' => 'search#index', as: :search


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
