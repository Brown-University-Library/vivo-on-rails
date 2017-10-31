Rails.application.routes.draw do
  # Support for original VIVO URLs
  get 'individual/sleep' => 'individual#slow_request' #REMOVE_TEST
  get 'individual/:id/:id.:format' => 'individual#export', as: :individual_export
  get 'individual/:id' => 'individual#redirect'
  get 'display/:id' => 'display#show', as: :display_show
  get 'display/' => 'display#index'

  get 'search_facets' => 'search#facets'
  get 'search/advanced' => 'search#advanced', as: :search_advanced
  get 'search' => 'search#index', as: :search

  get 'brown' => 'home#brown', as: :home_brown
  get 'about' => 'home#about', as: :home_about
  get 'faq' => 'home#faq', as: :home_faq
  get 'help' => 'home#help', as: :home_help
  get 'publications' => 'home#publications', as: :home_publications
  get 'roadmap' => 'home#roadmap', as: :home_roadmap
  get 'termsOfUse' => 'home#termsofuse', as: :home_terms
  root 'home#index'

  get '*path' => 'home#page_not_found'
end
