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

Removed development/tests gems since we are really not using them. This will force development to use MySQL rather than SQLite but that's OK. Less variations between environments.

No more warnings or errors needed to be addressed.


## MySQL gem error in dev server
I had to reset the mysql gem to '< 0.5' in Gemfile because our servers
don't have installed the required components for the latest version (0.5.3).

```
gem 'mysql2', '< 0.5'
```

...and run `bundle install` to update Gemfile.lock

The exact error that I got in dev was:

```
Fetching mysql2 0.5.3
Installing mysql2 0.5.3 with native extensions
Gem::Ext::BuildError: ERROR: Failed to build gem native extension.

    current directory: /opt/local/vivo-on-rails/vendor/bundle/ruby/2.7.0/gems/mysql2-0.5.3/ext/mysql2
/opt/local/rubies/ruby-2.7.1/bin/ruby -I /opt/local/rubies/ruby-2.7.1/lib/ruby/2.7.0 -r ./siteconf20200708-8555-sqc15a.rb extconf.rb
checking for rb_absint_size()... yes
checking for rb_absint_singlebit_p()... yes
checking for rb_wait_for_single_fd()... yes
-----
Using mysql_config at /usr/bin/mysql_config
-----
checking for mysql.h... yes
checking for errmsg.h... yes
checking for SSL_MODE_DISABLED in mysql.h... no
checking for MYSQL_OPT_SSL_ENFORCE in mysql.h... no
checking for MYSQL.net.vio in mysql.h... yes
checking for MYSQL.net.pvio in mysql.h... no
checking for MYSQL_ENABLE_CLEARTEXT_PLUGIN in mysql.h... no
checking for SERVER_QUERY_NO_GOOD_INDEX_USED in mysql.h... yes
checking for SERVER_QUERY_NO_INDEX_USED in mysql.h... yes
checking for SERVER_QUERY_WAS_SLOW in mysql.h... no
checking for MYSQL_OPTION_MULTI_STATEMENTS_ON in mysql.h... yes
checking for MYSQL_OPTION_MULTI_STATEMENTS_OFF in mysql.h... yes
checking for my_bool in mysql.h... yes
-----
Setting libpath to /usr/lib64/mysql
-----
creating Makefile

current directory: /opt/local/vivo-on-rails/vendor/bundle/ruby/2.7.0/gems/mysql2-0.5.3/ext/mysql2
make "DESTDIR=" clean

current directory: /opt/local/vivo-on-rails/vendor/bundle/ruby/2.7.0/gems/mysql2-0.5.3/ext/mysql2
make "DESTDIR="
compiling client.c
client.c: In function ‘rb_mysql_query’:
client.c:787: warning: passing argument 1 of ‘rb_rescue2’ from incompatible pointer type
/opt/local/rubies/ruby-2.7.1/include/ruby-2.7.0/ruby/ruby.h:1988: note: expected ‘VALUE (*)(VALUE)’ but argument is of type ‘VALUE (*)(void *)’
client.c:795: warning: passing argument 1 of ‘rb_rescue2’ from incompatible pointer type
/opt/local/rubies/ruby-2.7.1/include/ruby-2.7.0/ruby/ruby.h:1988: note: expected ‘VALUE (*)(VALUE)’ but argument is of type ‘VALUE (*)(void *)’
client.c: In function ‘_mysql_client_options’:
client.c:911: error: ‘MYSQL_DEFAULT_AUTH’ undeclared (first use in this function)
client.c:911: error: (Each undeclared identifier is reported only once
client.c:911: error: for each function it appears in.)
client.c: In function ‘set_default_auth’:
client.c:1350: error: ‘MYSQL_DEFAULT_AUTH’ undeclared (first use in this function)
At top level:
cc1: warning: unrecognized command line option "-Wno-used-but-marked-unused"
cc1: warning: unrecognized command line option "-Wno-static-in-inline"
cc1: warning: unrecognized command line option "-Wno-reserved-id-macro"
cc1: warning: unrecognized command line option "-Wno-missing-variable-declarations"
cc1: warning: unrecognized command line option "-Wno-documentation-unknown-command"
cc1: warning: unrecognized command line option "-Wno-disabled-macro-expansion"
cc1: warning: unrecognized command line option "-Wno-covered-switch-default"
cc1: warning: unrecognized command line option "-Wno-conditional-uninitialized"
cc1: warning: unrecognized command line option "-Wno-tautological-compare"
cc1: warning: unrecognized command line option "-Wno-self-assign"
cc1: warning: unrecognized command line option "-Wno-parentheses-equality"
cc1: warning: unrecognized command line option "-Wno-constant-logical-operand"
cc1: warning: unrecognized command line option "-Wno-cast-function-type"
make: *** [client.o] Error 1

make failed, exit code 2

Gem files will remain installed in /opt/local/vivo-on-rails/vendor/bundle/ruby/2.7.0/gems/mysql2-0.5.3 for inspection.
Results logged to /opt/local/vivo-on-rails/vendor/bundle/ruby/2.7.0/extensions/x86_64-linux/2.7.0-static/mysql2-0.5.3/gem_make.out

An error occurred while installing mysql2 (0.5.3), and Bundler cannot continue.
Make sure that `gem install mysql2 -v '0.5.3' --source 'https://rubygems.org/'` succeeds before bundling.

In Gemfile:
  mysql2
```


## MySQL error in dev

In the dev server `bundle exec rake db:migrate` complains that our MySQL is too old:

```
Your version of MySQL (5.1.73) is too old. Active Record supports MySQL >= 5.5.8.
```

I tried switching to SQLite so that we can run the development server but
then we got a similar error:

```
Your version of SQLite (3.6.20) is too old. Active Record supports SQLite >= 3.8.
```

So I set the Gemfile to use the latest mysql gem (0.5.3) again since we cannot
fallback to SQLite in the dev server.

This means that **we cannot run VIVO in the development environment** at this time
because that server does not have the minimum MySQL or SQLite required to run
a Rail 6.x application. We'll fix next week when Joe is back.

RAILS_ENV=production bundle config set path 'vendor/bundle'
RAILS_ENV=production bundle install
#RAILS_ENV=production bundle exec rake db:create
RAILS_ENV=production bundle exec rake db:migrate
#RAILS_ENV=production bundle exec rake vivo:book_covers_cache_init
RAILS_ENV=production bundle exec rake assets:precompile
RAILS_ENV=production bundle exec rails server


## Current status with MySQL in dev

Using `gem 'mysql2'` gives an error while running `bundle install` because we don't have the pre-requisits to build the gem with native extensions:

```
Fetching mysql2 0.5.3
Installing mysql2 0.5.3 with native extensions
Gem::Ext::BuildError: ERROR: Failed to build gem native extension.
```

Using `gem 'mysql2', '< 0.5'` allows `bundle install` to work but then the application will fail at runtime because our version of MySQL is too old. This is OK because we can point to a newer version of MySQL that we already have as soon as the database has been created by CIS.
