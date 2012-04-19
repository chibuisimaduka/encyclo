#!/usr/bin/python -O

import commands
import sys

if (!ENV["PARENT_ID"] || !ENV["TYPE"]): raise RuntimeError("Missing PARENT_ID or TYPE.") 

typename = sys.argv[1] 
parent_id = sys.argv[2]

# Helper method to execute a sql statement. It adds a semicolon.
def execute_sql(statement):
  return commands.getoutput('echo "' + statement + ';" | mysql -u root sorted_development')

def split_sql(statement):
  return execute_sql(statement).split('\n')

print("Loading the freebase entities.")
freebase_entities = {}
for freebase_attrs in split_sql("SELECT freebase_id,name FROM freebase_entities WHERE freebase_type='"+typename+"'"):
  freebase_tuple = freebase_attrs.split('\t')
  freebase_entities[freebase_tuple[0]] = freebase_typle[1]

print("Creating the entities.")
statement = "INSERT INTO entities (user_id,is_intermediate,parent_id,freebase_id) VALUES"
for freebase_id in freebase_entities
  statement += "(9,false,"+parent_id+","+freebase_id+"),"
execute_sql(statement[:-1])

print("Creating the names.")
statement = "INSERT INTO names (language_id,entity_id,value) VALUES"
for entity_attrs in split_sql("SELECT id,freebase_id FROM entities WHERE parent_id="+parent_id+" and freebase_id IS NOT NULL"):
  entity_tuple = entity_attrs.split('\t')
  statement += "(2,"+entity_tuple[0]+","+freebase_entities[entity_tuple[1]]+"),"
execute_sql(statement[:-1])

print("Creating the edit_requests.")
statement = "INSERT INTO edit_requests (editable_type,editable_id) VALUES"
for name_id in split_sql("SELECT id FROM names INNER JOIN entities ON names.entity_id = entities.id WHERE " +
        "entities.freebase_id IS NOT NULL and entities.parent_id="+parent_id):
  statement += "('Name',"+name_id+"),"
execute_sql(statement[:-1])

print("Creating the users_edit_requests.")
statement = "INSERT INTO users_edit_requests (user_id,edit_request_id) VALUES"
for edit_request_id in split_sql("SELECT id FROM edit_requests INNER JOIN names ON edit_requests.editable_name = 'Name' and edit_requests.editable_id = names._id " +
        "INNER JOIN entities ON names.entity_id = entities.id WHERE entities.freebase_id IS NOT NULL and entities.parent_id="+parent_id):
  statement += "(9,"+edit_request_id+"),"
execute_sql(statement[:-1])
