#!/usr/bin/python -O

import commands
import sys
import MySQLdb

if len(sys.argv) != 3: raise RuntimeError("Missing typename or parent_id.") 

typename = sys.argv[1] 
parent_id = sys.argv[2]

# Helper method to execute a sql statement.
def execute_sql(statement):
  db = MySQLdb.connect(host='localhost', user='root', db='sorted_development')
  return db.cursor().execute(statement).fetchall()

def split_sql(statement):
  return execute_sql(statement).split('\n')

def split_attrs(attrs):
  return attrs.split('\t')

sys.stderr.write("Loading the freebase entities.\n")
freebase_entities = {}
for freebase_attrs in split_sql("SELECT freebase_id,name FROM freebase_entities WHERE freebase_type='"+typename+"'")[1:]:
  freebase_tuple = split_attrs(freebase_attrs)
  freebase_entities[freebase_tuple[0]] = freebase_tuple[1]

sys.stderr.write("Creating the entities.\n")
statement = "INSERT INTO entities (user_id,is_intermediate,parent_id,freebase_id) VALUES"
for freebase_id in freebase_entities:
  statement += "(9,false,"+parent_id+",'"+freebase_id+"'),"
sys.stderr.write(execute_sql(statement[:-1]))

sys.stderr.write("Creating the names.\n")
statement = "INSERT INTO names (language_id,entity_id,value) VALUES"
for entity_attrs in split_sql("SELECT id,freebase_id FROM entities WHERE parent_id="+parent_id+" and freebase_id IS NOT NULL")[1:]:
  entity_tuple = split_attrs(entity_attrs)
  statement += "(2,"+entity_tuple[0]+",'"+freebase_entities[entity_tuple[1]].replace("'", '\'')+"'),"
sys.stderr.write(execute_sql(statement[:-1]))

sys.stderr.write("Creating the edit_requests.\n")
statement = "INSERT INTO edit_requests (editable_type,editable_id) VALUES"
for name_id in execute_sql("""SELECT id FROM names INNER JOIN entities ON names.entity_id = entities.id
        WHERE entities.freebase_id IS NOT NULL and entities.parent_id="""+parent_id):
  statement += "('Name',"+name_id+"),"
sys.stderr.write(execute_sql(statement[:-1]))

sys.stderr.write("Creating the users_edit_requests.\n")
statement = "INSERT INTO users_edit_requests (user_id,edit_request_id) VALUES"
for edit_request_id in execute_sql("""SELECT id FROM edit_requests INNER JOIN names ON edit_requests.editable_name = 'Name' and edit_requests.editable_id = names._id 
        INNER JOIN entities ON names.entity_id = entities.id WHERE entities.freebase_id IS NOT NULL and entities.parent_id="""+parent_id):
  statement += "(9,"+edit_request_id+"),"
sys.stderr.write(execute_sql(statement[:-1]))
