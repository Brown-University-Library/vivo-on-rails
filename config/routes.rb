Rails.application.routes.draw do

  get 'sparql/query' => 'sparql#query'
  # TODO: use POST for submit
  # post 'sparql/query' => 'sparql#submit'

  # Support for original VIVO URLs
  get 'individual/:id/:id.:format' => 'individual#export', as: :individual_export
  get 'individual/:id' => 'individual#redirect'
  get 'display/:id' => 'display#show', as: :display_show
  get 'display/' => 'display#index'

  # Use specific URLs (people/org) for links that don't exist in VIVO.
  get 'people/:id/resolr' => 'faculty#resolr', as: :faculty_resolr
  get 'organization/:id/resolr' => 'organization#resolr', as: :organization_resolr

  get 'search_facets' => 'search#facets'
  get 'search' => 'search#index'

  get 'about' => 'home#about', as: :home_about
  get 'faq' => 'home#faq', as: :home_faq
  get 'help' => 'home#help', as: :home_help
  get 'publications' => 'home#publications', as: :home_publications
  get 'roadmap' => 'home#roadmap', as: :home_roadmap
  get 'termsOfUse' => 'home#termsofuse', as: :home_terms
  root 'home#index'
end
