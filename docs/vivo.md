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

for each triple
  if value is literal
    # display it
  else
    # follow recursively
    # unless predicate is <http://www.w3.org/1999/02/22-rdf-syntax-ns#type>
  end
