# VIVO Viewer

This is a proof of concept at creating a Rails application to
browse through the researcher information stored in a VIVO database.

The application works by querying the SPARQL endpoint that
VIVO provides.

The CSS styles used on this web site were taken from [Symplectic's
bootstrap template](https://www.digital-science.com/blog/news/introducing-bootstrapped-vivo-symplectic-reimagines-vivo-research-profile-design/)

# To get started
```
git clone this repo
cd vivo-on-rails
bundle install
source .env_sample
bundle exec rails server
```

# To run the tests
```
bundle exec rails vivo:tests
```
