# VIVO Viewer

This is a proof of concept at creating a Rails application to
browse through the researcher information stored in a VIVO database.

The application works by querying the SPARQL endpoint that
VIVO provides.

The CSS styles used on this web site were taken from [Symplectic's
bootstrap template](https://www.digital-science.com/blog/news/introducing-bootstrapped-vivo-symplectic-reimagines-vivo-research-profile-design/)

# Pre-requisites
You need to have [Solr]http://lucene.apache.org/solr/ and [Fuseki](https://jena.apache.org/index.html) installed and running.

```
fuseki start
solr start
```


# To get started
```
git clone this repo
cd vivo-on-rails
bundle install
source .env_sample
bundle exec rails server
```

You'll need to tweak the values in `.env_sample` to match the URLs where
Solr and Fuseki are running in your environment.

# To run the tests
```
bundle exec rails vivo:tests
```

# Solr 6
```
# Create core
solr create_core -c vivo
```
