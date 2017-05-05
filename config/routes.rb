Rails.application.routes.draw do

  get 'sparql/query' => 'sparql#query'
  # TODO: this should be post
  get 'sparql/query_submit' => 'sparql#submit', as: :sparql_submit

  get 'faculty2/:id/resolr' => 'faculty2#resolr', as: :faculty_resolr
  get 'faculty2/:id' => 'faculty2#show', as: :faculty_show
  get 'faculty/:id' => 'faculty#show' #, as: :faculty_show
  get 'faculty/' => 'faculty#index'

  get 'search_facets' => 'search#facets'
  get 'search' => 'search#index'

  get 'home' => 'home#index'
  get 'about' => 'home#about'

  get 'organization/:id' => 'organization#show', as: :organization_show
  get 'organization/' => 'organization#index'

  # You can have the root of your site routed with "root"
  root 'home#index'
end
