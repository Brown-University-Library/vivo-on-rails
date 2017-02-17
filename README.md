# VIVO on Rails

This is a proof of concept at creating a Rails application to browse through the
researcher information stored in a VIVO database and a SOLR index.

The CSS styles used on this web site were taken from
[Symplectic's bootstrap template](https://www.digital-science.com/blog/news/introducing-bootstrapped-vivo-symplectic-reimagines-vivo-research-profile-design/)


# Pre-requisites
You need to have [Solr](http://lucene.apache.org/solr/) and
[Fuseki](https://jena.apache.org/index.html) installed and running.

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
This is a Ruby on Rails web site that shows faculty information stored in Solr.
All searches and retrieval of information are done against Solr.

The information is assumed to come from a Fuseki instance with VIVO information
but the site does not interface with Fuseki except in a few `rake` tasks to
populate the Solr index.

In the future, access to Fuseki triple store will be used to perform linked
data queries and other visualizations.

A few diagrams on how the project is structure can be found
[here](https://docs.google.com/presentation/d/1envsRrRUw_1MXzHIqqvhhwILbTx7eH0inWG8MwTMFds/edit?usp=sharing)


# Solr Index
The site assumes that the Solr index has *Faculty* information stored in a
structure like the following:

````
  {
    id: "http://vivo.brown.edu/individual/jane_researcher",
    record_type: "PEOPLE",
    affiliations: ["dept1", "dept2", ... "deptN"],
    research_areas":["r1", "r2", "r3", ... "rN"],
    json_txt: "# string representation of a JSON object with the all the data (see below)"
  }
````

Below is a sample of the data stored in `json_txt` for a sample PEOPLE document.
Notice that the field is a string with the JSON of the data for the given
document.

```
"{
  \"record_type\":\"PEOPLE\",
  \"affiliations_text\":\"\",
  \"affiliations\":[
    {
      \"uri\":\"http://vivo.brown.edu/individual/org-brown-univ-dept57\",
      \"name\":\"Pathology and Laboratory Medicine\",
      \"id\":\"http://vivo.brown.edu/individual/org-brown-univ-dept57\"
    }
  ],
  \"awards\":\"\",
  \"collaborators\":[],
  \"contributor_to\":[],
  \"education\":[
    {
      \"school_uri\":\"http://vivo.brown.edu/individual/n37819\",
      \"date\":\"1980\",
      \"degree\":\"BA\",
      \"school_name\":\"Mount Holyoke College\"
    },
    {
      \"school_uri\":\"http://vivo.brown.edu/individual/n67738\",
      \"date\":\"1985\",
      \"degree\":\"MD\",
      \"school_name\":\"State University of New York\"
    }
  ],
  \"email\":\"H_Katrine_Hansen@brown.edu\",
  \"funded_research\":\"\",
  \"name\":\"Hansen, Katrine\",
  \"org_label\":\"Pathology and Laboratory Medicine\",
  \"overview\":\"\",
  \"research_overview\":\"\",
  \"research_statement\":\"\",
  \"scholarly_work\":\"\",
  \"teacher_for\":[],
  \"teaching_overview\":\"\",
  \"title\":\"Associate Professor of Pathology and Laboratory Medicine\",
  \"thumbnail\":null,
  \"research_areas\":[],
  \"uri\":\"http://vivo.brown.edu/individual/khansenm\",
  \"id\":\"http://vivo.brown.edu/individual/khansenm\"
}"
```

*Organization* records follow a similar pattern.

````
  {
    id: "http://vivo.brown.edu/individual/some-org-id",
    record_type: "ORGANIZATION",
    json_txt: "# string representation of a JSON object with the all the data (see below)"
  }
````

Below is a sample of the data stored in `json_txt` for a sample ORGANIZATION.
Notice that the field is a string with the JSON of the data for the given
document.

```
"{
  \"record_type\":\"ORGANIZATION\",
  \"uri\":\"http://vivo.brown.edu/individual/org-brown-univ-dept57\",
  \"name\":\"Pathology and Laboratory Medicine\",
  \"overview\":...",
  \"thumbnail\":\"http://vivo.brown.edu/individual/n5457\",
  \"people\":[
  {
    \"id\":\"http://vivo.brown.edu/individual/khansenm\",
    \"uri\":\"http://vivo.brown.edu/individual/khansenm\",
    \"label\":\"Hansen, Katrine\",
    \"specific_position\":\"Associate Professor of Pathology and Laboratory Medicine\",
    \"general_position\":\"Faculty Position\"
  },
  {
    \"id\":\"http://vivo.brown.edu/individual/elaposat\",
    \"uri\":\"http://vivo.brown.edu/individual/elaposat\",
    \"label\":\"\",
    \"specific_position\":\"Clinical Associate Professor of Pathology and Laboratory Medicine\",
    \"general_position\":\"Faculty Position\"
  }]
}
```

We use `json_txt` to reconstruct the data that will be displayed when the user
wants to view the detail for a specific individual or organization. This is what
allows us to run the system without interfacing with the Fuseki endpoint.

**TODO:** We still need to create individual fields in Solr to allow for a better
search experience, for example, a separate field for name to give it a higher
boost on search results and the ability to facet the data by other fields.


# To populate Solr
There are a couple of `rake` tasks that can be used to push to Solr a set of
faculty and organizations from your VIVO triple store into Solr.

```
bundle exec rake vivo:solrize_org_all
bundle exec rake vivo:solrize_faculty_all
```

# Caveats
This is a proof of concept at this point.

The code at this point is hard-coded for very specific predicates
that we use at Brown and might not work on your particular VIVO database.

The unit tests (`bundle exec rake vivo:tests`) are hard-coded to find very
specific people/departments so they will very likely fail on your installation.
