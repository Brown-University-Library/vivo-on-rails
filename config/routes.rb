Rails.application.routes.draw do
  # Support for original VIVO URLs
  get 'individual/:id/:id.:format' => 'individual#export', as: :individual_export
  get 'individual/:id' => 'individual#redirect'
  get 'display/:id' => 'display#show', as: :display_show
  get 'display/' => 'display#index'

  # Editor
  get 'edit/fast/search' => 'edit#fast_search'
  post 'edit/overview/:faculty_id/update' => 'edit#overview_update'
  post 'edit/research_area/:faculty_id/add' => 'edit#research_area_add'
  post 'edit/research_area/:faculty_id/delete' => 'edit#research_area_delete'
  post 'edit/web_link/:faculty_id/save' => 'edit#web_link_save'
  post 'edit/web_link/:faculty_id/delete' => 'edit#web_link_delete'
  post 'edit/research/overview/:faculty_id/update' => 'edit#research_overview_update'
  post 'edit/research/statement/:faculty_id/update' => 'edit#research_statement_update'
  post 'edit/research/funded/:faculty_id/update' => 'edit#research_funded_update'
  post 'edit/research/scholarly/:faculty_id/update' => 'edit#research_scholarly_update'
  post 'edit/background/awards/:faculty_id/update' => 'edit#background_awards_update'
  post 'edit/affiliations/text/:faculty_id/update' => 'edit#affiliations_text_update'
  post 'edit/teaching/overview/:faculty_id/update' => 'edit#teaching_overview_update'
  get 'edit/:id' => 'display#edit', as: :display_edit

  # Visualizations for faculty (and organizations)
  get 'display/:id/viz/coauthor' => 'visualization#coauthor', as: :visualization_coauthor
  get 'display/:id/viz/coauthor_treemap' => 'visualization#coauthor_treemap', as: :visualization_coauthor_treemap
  get 'display/:id/viz/collab' => 'visualization#collab', as: :visualization_collab
  get 'display/:id/viz/publications' => 'visualization#publications', as: :visualization_publications
  get 'display/:id/viz/research' => 'visualization#research', as: :visualization_research
  get 'display/:id/viz' => 'visualization#home', as: :visualization_home

  # Reports by subject librarian
  get 'reports/subject-lib/:list_id' => 'reports#subject_lib', as: :reports_subject_lib
  get 'reports/subject-lib' => 'reports#subject_lib_list'

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
  get 'help/viz' => 'home#help_viz', as: :home_help_viz
  get 'help' => 'home#help', as: :home_help
  get 'history' => 'home#history', as: :home_history
  get 'publications' => 'home#publications', as: :home_publications
  get 'roadmap' => 'home#roadmap', as: :home_roadmap
  get 'termsOfUse' => 'home#termsofuse', as: :home_terms
  get 'status' => 'home#status'
  get 'side_stuff/brown_classic/:name' => 'home#brown_classic'
  get 'side_stuff/brown_classic/' => 'home#brown_classic'

  root 'home#index'

  get '*path' => 'home#page_not_found'
end
