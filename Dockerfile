# # Use the Ruby 2.7.1 image from Docker Hub
# # as the base image (https://hub.docker.com/_/ruby)
# # Using alpine because of blacklight
# FROM ruby:2.7.1-alpine

# # # Use a directory called /code in which to store
# # # this application's files. (The directory name
# # # is arbitrary and could have been anything.)
# # WORKDIR /code

# # # Copy all the application's files into the /code
# # # directory.
# # COPY . /code

# # # Run bundle install to install the Ruby dependencies.
# # RUN bundle install

# # # Install Yarn.
# # # RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
# # # RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
# # RUN apt-get update && apt-get install -y yarn

# # # Run yarn install to install JavaScript dependencies.
# # RUN yarn install

# # # Set "rails server -b 0.0.0.0" as the command to
# # # run when this container starts.
# # CMD ["rails", "server", "-b", "0.0.0.0"]

# RUN apk add --update --no-cache \
#   bash \
#   git \
#   nodejs \
#   yarn

# RUN mkdir /app
# WORKDIR /app

# COPY . .

# # RUN gem update --system && \
# #   gem install bundler && \
# #   bundle config build.nokogiri --use-system-libraries

# # RUN bundle install --deployment && \
# #   gem install bundler -v 2.4.22 && \
# #   bundle config build.nokogiri --use-system-libraries

# # RUN dnf install -y zlib-devel xz patch
# # RUN gem install nokogiri -v 1.15.7 --platform=ruby

# RUN bundle config set path 'vendor/bundle'

# # RUN apk add --no-cache build-base && \
# #   gem install nokogiri -v 1.15.7 --platform=ruby && \
# #   apk del --no-network build-base

# RUN apk add ruby ruby-nokogiri

# RUN bundle install
# #   bundle exec rake db:create && \
# #   bundle exec rake db:migrate
# #   bundle exec rails server
# # RUN bundle config build.nokogiri --use-system-libraries

# EXPOSE 3000

# # Set "rails server -b 0.0.0.0" as the command to
# # run when this container starts.
# CMD ["rails", "server", "-b", "0.0.0.0"]

# The "builder" image will build nokogiri
FROM ruby:2.7.1-alpine AS builder

# Nokogiri's build dependencies
RUN apk add --update \
  build-base \
  libxml2-dev \
  libxslt-dev

# Nokogiri, yikes
RUN echo 'source "https://rubygems.org"; gem "nokogiri"' > Gemfile

RUN bundle install

# The final image: we start clean
FROM ruby:2.7.1-alpine

# We copy over the entire gems directory for our builder image, containing the already built artifact
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/

EXPOSE 3000

# Set "rails server -b 0.0.0.0" as the command to
# run when this container starts.
CMD ["rails", "server", "-b", "0.0.0.0"]