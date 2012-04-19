#!/usr/bin/python -O

import commands
import sys
import MySQLdb

if len(sys.argv) != 3: raise RuntimeError("Missing typename or parent_id.") 

typename = sys.argv[1] 
parent_id = sys.argv[2]

def execute_sql(statement):
  db = MySQLdb.connect(host='localhost', user='root', db='sorted_development')
  c = db.cursor()
  c.execute(statement)
  db.close()

def query_sql(statement):
  db = MySQLdb.connect(host='localhost', user='root', db='sorted_development')
  c = db.cursor()
  c.execute(statement)
  result = c.fetchall()
  db.close()
  return result

sys.stderr.write("Loading the freebase entities.\n")
freebase_entities = {}
for freebase_attrs in query_sql("SELECT freebase_id,name FROM freebase_entities WHERE freebase_type='"+typename+"'")[1:]:
  freebase_entities[freebase_attrs[0]] = freebase_attrs[1]

sys.stderr.write("Creating the entities.\n")
statement = "INSERT INTO entities (user_id,is_intermediate,parent_id,freebase_id) VALUES"
for freebase_id in freebase_entities:
  statement += "(9,false,"+parent_id+",'"+freebase_id+"'),"
execute_sql(statement[:-1])

sys.stderr.write("Creating the names.\n")
statement = "INSERT INTO names (language_id,entity_id,value) VALUES"
for entity_attrs in query_sql("SELECT id,freebase_id FROM entities WHERE parent_id="+parent_id+" and freebase_id IS NOT NULL")[1:]:
  statement += "(2,"+entity_attrs[0]+",'"+freebase_entities[entity_attrs[1]].replace("'", '\'')+"'),"
execute_sql(statement[:-1])

sys.stderr.write("Creating the edit_requests.\n")
statement = "INSERT INTO edit_requests (editable_type,editable_id) VALUES"
for name_id in query_sql("""SELECT id FROM names INNER JOIN entities ON names.entity_id = entities.id
        WHERE entities.freebase_id IS NOT NULL and entities.parent_id="""+parent_id):
  statement += "('Name',"+name_id+"),"
execute_sql(statement[:-1])

sys.stderr.write("Creating the users_edit_requests.\n")
statement = "INSERT INTO users_edit_requests (user_id,edit_request_id) VALUES"
for edit_request_id in query_sql("""SELECT id FROM edit_requests INNER JOIN names ON edit_requests.editable_name = 'Name' and edit_requests.editable_id = names._id 
        INNER JOIN entities ON names.entity_id = entities.id WHERE entities.freebase_id IS NOT NULL and entities.parent_id="""+parent_id):
  statement += "(9,"+edit_request_id+"),"
execute_sql(statement[:-1])
