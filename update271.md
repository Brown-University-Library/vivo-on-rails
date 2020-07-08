# Upgrading to Ruby 2.7.1 and Rails 5.2

## Updating Gemfile
Upgraded version of Rails in Gemfile

```
gem 'rails', '~> 5.2.4'
```

`bundle install` gave error about conflicting versions, had to comment:

```
gem 'jquery-rails'
gem 'dotenv-rails'
```

Once it worked, I was able to restore `gem 'dotenv-rails'` and `gem 'jquery-rails'`

Once these dependencies have been resolved this was not a problem in production.


## Error about manifest.js

Got error "Expected to find a manifest file in `app/assets/config/manifest.js` (Sprockets::Railtie::ManifestNeededError)
But did not, please create this file and use it to link any assets that need to be rendered by your app"

This fixes it: https://stackoverflow.com/questions/58339607/why-does-rails-fails-to-boot-with-expected-to-find-a-manifest-file-in-app-asse


## Error about raise_in_transactional_callbacks

Got error: "Undefined method raise_in_transactional_callbacks=' for ActiveRecord::Base:Class (NoMethodError)"

This fixes it: https://stackoverflow.com/questions/28006358/undefined-method-raise-in-transactional-callbacks-for-activerecordbaseclass


## Warning about config.i18n.fallbacks

Bundle update reported a warning from the i18n 1.1 gem about the value
for the config.i18n.fallbacks setting.

Updated the setting in `./config/environments/production.rb` to use the recommended value.


# Running

Set the values in the .env file to define the database and the secrets key, then:

```
RAILS_ENV=production bundle config set path 'vendor/bundle'
RAILS_ENV=production bundle install
RAILS_ENV=production bundle exec rake db:create
RAILS_ENV=production bundle exec rake db:migrate
RAILS_ENV=production bundle exec rake assets:precompile
RAILS_ENV=production bundle exec rails server
```

In dev [Bundler 2.x](https://bundler.io/guides/bundler_2_upgrade.html) already was installed, but if not I might need to install it:

```
bundle update --bundler
```


# Production changes

```
chruby 2.7.1
# gem install bundler:1.17.1
sudo /etc/init.d/httpd restart
```

# Upgrading to Rails 6.0.3

Like before, upgraded version of Rails in Gemfile `gem 'rails', '~> 6.0.2'` and `bundle install` gave error about conflicting versions. I had to comment `gem 'jquery-rails'` and `gem 'dotenv-rails'`, run `bundle install` again which gave no conflicts, restore these gems in Gemfile, and run `bundle install` once more.
```

Removed development/tests gems since we are really not using them. This will force development to use MySQL rather than SQLite but that's OK. Less variations between environments.

No more warnings or errors needed to be addressed.


