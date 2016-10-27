# VIVO on Rails

This is a proof of concept at creating a Rails application to browse through the researcher information stored in a VIVO database and a SOLR index.

The CSS styles used on this web site were taken from
[Symplectic's bootstrap template](https://www.digital-science.com/blog/news/introducing-bootstrapped-vivo-symplectic-reimagines-vivo-research-profile-design/)


# Pre-requisites
You need to have [Solr](http://lucene.apache.org/solr/) and [Fuseki](https://jena.apache.org/index.html) installed and running.

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


# General Architecture
This is a Ruby on Rails web site that shows faculty information stored in Solr. All searches and retrieval of information are done against Solr.

The information is assumed to come from a Fuseki
instance with VIVO information but the site does not interface
with Fuseki except in a few `rake` tasks to populate the Solr index.

The site assumes that the Solr index has Faculty information stored in a structure like the following:

````
  {
    record_type: "FACULTY",
    uri: "http://vivo.brown.edu/individual/jane_researcher",
    text: "{string with the JSON representation of the record}"
    affiliations: ["dept1", "dept2", "deptN"]
  }
````
Organization records follow a similar pattern.


Access to Fuseki triple store will be used to perform linked
data queries and other visualizations.


# To populate Solr
There are a couple of `rake` tasks that can be used to push to Solr a set of faculty and organizations from your VIVO triple store into Solr.

```
bundle exec rake vivo:solrize_org_all
bundle exec rake vivo:solrize_faculty_all
```

# Creating a core in Solr 4.7.x
cd solr-4.7.2/example/solr/
mkdir vivo-on-rails
cd vivo-on-rails
cp -r ../collection1/conf/ conf/
curl "http://localhost:8983/solr/admin/cores?action=CREATE&name=vivo-on-rails&instanceDir=vivo-on-rails"


# Caveats
This is a proof of concept at this point.

The code at this point is hard-coded for very specific predicates
that we use at Brown and might not work on your particular VIVO database.

The unit tests (`bundle exec rails vivo:tests`) are hard-coded to find very specific people/departments so they will very likely fail on your installation.
