source 'https://rubygems.org'

gem 'rails', '~> 4.2.7.1'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

group :production do
  gem 'mysql2'
end

group :development, :test do
  gem "sqlite3"
  gem "byebug"                # debugger
  gem "better_errors"         # web page for errors
  gem "binding_of_caller"     # allows inspecting values in web error page
  gem 'web-console', '~> 2.0' # Access an IRB console on exception pages or by using <%= console %> in views
end

# Needed on RedHat
gem 'therubyracer', platforms: :ruby

# Needed for rails console in RedHat
gem "rb-readline"

# Loads environment settings from .env file
# See https://github.com/bkeepers/dotenv
gem 'dotenv-rails'

gem "solr_lite", '0.0.5'
