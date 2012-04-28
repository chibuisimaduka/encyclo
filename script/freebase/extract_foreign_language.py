#!/usr/bin/python -O

import sys
import utils

if len(sys.argv) != 3: raise RuntimeError("Usage: extract_name.py 862(parent_id) path/to/data/dump")

parent_id = sys.argv[1]
filename = sys.argv[2]

languages = {
  "fr": 1,
  "en": 2,
  "es": 3,
  "it": 36
}
missing_languages = set()

ids = dict(utils.query_sql("SELECT freebase_id,id FROM entities WHERE parent_id = " + parent_id))

print("Parsing the data dump.")
statement = "INSERT INTO names (language_id,entity_id,value) VALUES"
for line in open(filename, 'r'):
  if (line[line.index('\t')+1:].startswith("/type/object/name\t/lang/")):
    lang = line[line.index("/lang/")+6:line.rindex('\t')]
    if lang != "en" and lang in languages:
      freebase_id = line[:line.index('\t')]
      if freebase_id in ids:
        statement += "("+str(languages[lang])+","+str(ids[freebase_id])+",'"+line[line.rindex('\t')+1:-1].replace("'", '\\\'')+"'),"
    elif lang not in missing_languages:
      print("Missing language " + lang)
      missing_languages.add(lang)
sys.stderr.write(statement[:-1] + ";")
utils.commit_sql(statement[:-1])

print("Creating the edit_requests.")
statement = "INSERT INTO edit_requests (editable_type,editable_id) VALUES"
for name_attrs in utils.query_sql("""SELECT names.id FROM names
        INNER JOIN entities ON names.entity_id = entities.id
        WHERE entities.freebase_id IS NOT NULL and entities.parent_id="""+parent_id):
  statement += "('Name',"+str(name_attrs[0])+"),"
utils.commit_sql(statement[:-1])

print("Creating the users_edit_requests.")
statement = "INSERT INTO users_edit_requests (user_id,edit_request_id) VALUES"
for edit_request_attrs in utils.query_sql("""SELECT edit_requests.id FROM edit_requests
        INNER JOIN names ON edit_requests.editable_type = 'Name' and edit_requests.editable_id = names.id 
        INNER JOIN entities ON names.entity_id = entities.id
        WHERE entities.freebase_id IS NOT NULL and entities.parent_id="""+parent_id):
  statement += "(9,"+str(edit_request_attrs[0])+"),"
utils.commit_sql(statement[:-1])
