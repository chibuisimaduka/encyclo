#!/usr/bin/python -O

import sys
import utils

if len(sys.argv) != 3: raise RuntimeError("Missing typename or parent_id.") 

typename = sys.argv[1] 
parent_id = sys.argv[2]

sys.stderr.write("Loading the freebase entities.\n")
freebase_entities = {}
for freebase_attrs in utils.query_sql("SELECT freebase_id,name FROM freebase_entities WHERE freebase_type='"+typename+"'")[1:]:
  freebase_entities[freebase_attrs[0]] = freebase_attrs[1]

sys.stderr.write("Creating the entities.\n")
statement = "INSERT INTO entities (user_id,is_intermediate,parent_id,freebase_id) VALUES"
for freebase_id in freebase_entities:
  statement += "(9,false,"+parent_id+",'"+freebase_id+"'),"
utils.commit_sql(statement[:-1])

sys.stderr.write("Creating the names.\n")
statement = "INSERT INTO names (language_id,entity_id,value) VALUES"
for entity_attrs in utils.query_sql("SELECT id,freebase_id FROM entities WHERE parent_id="+parent_id+" and freebase_id IS NOT NULL")[1:]:
  if not freebase_entities[entity_attrs[1]]:
    sys.stderr.write("Missing freebase_id=" + entity_attrs[1] + "\n")
  else:
    statement += "(2,"+str(entity_attrs[0])+",'"+freebase_entities[entity_attrs[1]].replace("'", '\\\'')+"'),"
utils.commit_sql(statement[:-1])

sys.stderr.write("Creating the edit_requests.\n")
statement = "INSERT INTO edit_requests (editable_type,editable_id) VALUES"
for name_attrs in utils.query_sql("""SELECT names.id FROM names
        INNER JOIN entities ON names.entity_id = entities.id
        WHERE entities.freebase_id IS NOT NULL and entities.parent_id="""+parent_id):
  statement += "('Name',"+str(name_attrs[0])+"),"
utils.commit_sql(statement[:-1])

sys.stderr.write("Creating the users_edit_requests.\n")
statement = "INSERT INTO users_edit_requests (user_id,edit_request_id) VALUES"
for edit_request_attrs in utils.query_sql("""SELECT edit_requests.id FROM edit_requests
        INNER JOIN names ON edit_requests.editable_type = 'Name' and edit_requests.editable_id = names.id 
        INNER JOIN entities ON names.entity_id = entities.id
        WHERE entities.freebase_id IS NOT NULL and entities.parent_id="""+parent_id):
  statement += "(9,"+str(edit_request_attrs[0])+"),"
utils.commit_sql(statement[:-1])
