# VIVO on Rails
This is the code for the new VIVO front-end for [Researchers@Brown](https://vivo.brown.edu). This is a
Ruby on Rails application that searches directly against the VIVO's Solr
index. See the General Architecture information below for more details.


# Pre-requisites
You need to have [Solr](http://lucene.apache.org/solr/) running. We use the
Solr index that VIVO provides out of the box but we have added several fields
needed by this project. See **Solr Index** section below.

We are currently using Ruby 2.3.5, Rails 4.2.7, and MySQL.

```
brew install ruby-install
brew install chruby
ruby-install ruby 2.3.5
source /usr/local/opt/chruby/share/chruby/chruby.sh
chruby 2.3.5
brew install mysql
gem install bundle
```

# To get started
```
git https://github.com/Brown-University-Library/vivo-on-rails.git
cd vivo-on-rails
bundle install
source .env_sample
bundle exec rake db:migrate
bundle exec rails server
```

Update the values in `.env_sample` to match the URLs where Solr is running in
your environment.


# General Architecture
This is a Ruby on Rails web site that shows faculty information stored in Solr.
All searches and retrieval of information are done against Solr.

In the future, access to the Fuseki triple store will be used to perform linked
data queries and other visualizations.

A few diagrams on how the project is structure can be found
[here](https://docs.google.com/presentation/d/1eXatLlX-VOkjPeJqYRZ7AhzkMK96XrQfykX1rvDdJKE/edit?usp=sharing)


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


# Caveats
The code at this point is hard-coded for very specific predicates that we use
at Brown and might not work on your particular VIVO database.

The unit tests (`bundle exec rake vivo:tests`) are hard-coded to find very
specific people/departments so they will very likely fail on your installation.


# Sidenote
*An older version of this project* included code to create a Solr index by querying
VIVO's Fuseki endpoint. We have moved away from this approach. In the current
version we use the native Solr index with a few extra fields that we have added
to support the functionality that we need. If you are interested in the code
that we used back then you can still find the models under
`./app/models/fuseki` and the rake tasks under `./lib/tasks/fuseki_solrize.rake`.
