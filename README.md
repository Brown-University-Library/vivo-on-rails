# VIVO Viewer

This is a proof of concept at creating a Rails application to
browse through the researcher information stored in a VIVO database
and a SOLR index.

The application works by querying the SPARQL endpoint that
VIVO provides to fetch detailed information about people and
organizations. Searches are performed through Solr.

The CSS styles used on this web site were taken from
[Symplectic's bootstrap template](https://www.digital-science.com/blog/news/introducing-bootstrapped-vivo-symplectic-reimagines-vivo-research-profile-design/)


# Pre-requisites
You need to have [Solr]http://lucene.apache.org/solr/ and [Fuseki](https://jena.apache.org/index.html) installed and running.

```
fuseki start
solr start
solr create_core -c vivo
```


# To get started
```
git https://github.com/Brown-University-Library/vivo-on-rails.git
cd vivo-on-rails
bundle install
source .env_sample
bundle exec rails server
```

You'll need to tweak the values in `.env_sample` to match the URLs where
Solr and Fuseki are running in your environment.


# To populate Solr
The following `rake` tasks will push to Solr the first 100 faculty
and first 100 organizations in your VIVO triple store into Solr.

```
bundle exec rake vivo:solrize_org_all
bundle exec rake vivo:solrize_faculty_all
```

# Caveats
This is a proof of concept at this point.

The code at this point is hard-coded for very specific predicates
that we use at Brown and might not work on your particular VIVO database.

The unit tests (`bundle exec rails vivo:tests` are hard-coded to find very
specific people/departments so they will very likely fail on your installation.
