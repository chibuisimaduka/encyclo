#!/usr/bin/python -O

import sys
import utils

if len(sys.argv) != 3: raise RuntimeError("Usage: extract_name.py /freebase/type/name path/to/data/dump")

typename = sys.argv[1]
filename = sys.argv[2]

freebase_entities = set(map(utils.first, utils.query_sql("SELECT freebase_id FROM freebase_entities WHERE freebase_type='"+typename+"'")[1:]))

print("Starting to fetch entries..")

statement = "INSERT INTO freebase_entities (freebase_id,name) VALUES "
nb = 0
for line in open(filename, 'r'):
  index = line.index('\t')
  if (line[index+1:].startswith("/type/object/name\t/lang/en")):
    entity_id = line[:index]
    if (entity_id in ids):
      rindex = line.rindex('\t') + 1
      statement += '("' + entity_id + '","' + line[rindex:-1].replace('"', '\\"') + '"),'
      nb += 1

statement = statement[:-1] # Strip the extra comma
statement += " ON DUPLICATE KEY UPDATE name=VALUES(name);"

print("Fetching entries done!")
print("Found " + str(nb) + " matching entries.")

utils.commit_sql(statement)

print("Entering entries done!")
