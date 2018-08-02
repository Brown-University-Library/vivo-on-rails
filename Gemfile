source 'https://rubygems.org'

gem 'rails', '~> 4.2.7.1'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use jquery as the JavaScript library
gem 'jquery-rails'

group :production do
  # Force it to under < 0.5 to bypass error when executing `bundle exec rake db:migrate`
  #   Gem::LoadError: can't activate mysql2 (< 0.5, >= 0.3.13),
  #   already activated mysql2-0.5.2. Make sure all dependencies are added to Gemfile.
  gem 'mysql2', '< 0.5'
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
