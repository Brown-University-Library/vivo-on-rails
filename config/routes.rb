Rails.application.routes.draw do

  get 'sparql/query' => 'sparql#query'
  # TODO: this should be post
  get 'sparql/query_submit' => 'sparql#submit', as: :sparql_submit

  # Support for original VIVO URLs
  get 'individual/:id/:id.:format' => 'individual#export'
  get 'individual/:id' => 'individual#redirect'
  get 'display/:id' => 'display#show', as: :display_show
  get 'display/' => 'display#index'

  # Use specific URLs (people/org) for links that don't exist in VIVO.
  get 'people/:id/resolr' => 'faculty#resolr', as: :faculty_resolr
  get 'organization/:id/resolr' => 'organization#resolr', as: :organization_resolr

  get 'search_facets' => 'search#facets'
  get 'search' => 'search#index'

  get 'about' => 'home#about'
  root 'home#index'
end
