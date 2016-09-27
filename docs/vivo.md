# Fetch all predicates

```
select distinct ?p
where { ?s ?p ?o . }
```

# Fetch all faculty

```
select distinct ?s
where { ?s ?p <http://vivoweb.org/ontology/core#FacultyMember> . }
```


# All predicate/values for faculty
# <http://vivo.brown.edu/individual/cmacdonn>

```
select ?p ?o
where
{
  <http://vivo.brown.edu/individual/cmacdonn> ?p ?o .
}
```

# To delete all data
# Issue this against the /update endpoint

```
delete
where { ?s ?p ?o .}
```
