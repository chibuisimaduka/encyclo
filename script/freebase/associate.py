#!/usr/bin/python -O

# Scenario: For every movie, create associations for every performances.

import sys
import utils

# Command line arguments:
if len(sys.argv) < 5: raise RuntimeError("Usage: associate.py 24(association_definition_id) false(is_reversed) /property/property/id /path/to/data/dump [is_date]")

association_definition_id = sys.argv[1]
association_reversed = (sys.argv[2] == 'true')
property_id = sys.argv[3] # Ex: /film/film/starring
filename = sys.argv[4]
is_date = bool(sys.argv[5])

if is_date: import time

parent_id, associated_parent_id = utils.query_sql("SELECT entity_id,associated_entity_id FROM association_definitions WHERE id=" + association_definition_id)[0]

def get_entities_dict(parent_id):
  return dict(utils.query_sql("select freebase_id,id from entities where freebase_id IS NOT NULL and parent_id=" + str(parent_id)))

entities = get_entities_dict(parent_id if not association_reversed else associated_parent_id)
if is_date:
  associated_entities = dict(utils.query_sql("""SELECT names.value,entities.id FROM entities
      INNER JOIN names ON names.entity_id = entities.id WHERE entities.parent_id=""" + str(associated_parent_id)))
else:
  associated_entities = get_entities_dict(associated_parent_id if not association_reversed else parent_id)

print("Starting to fetch entries..")

statement="INSERT INTO associations (user_id,association_definition_id,entity_id,associated_entity_id) VALUES"
num_entries = 0
for line in open(filename, 'r'):
  line = line[:-1] # Strip the newline.
  entity_id = line[:line.index('\t')]
  if entity_id in entities and line[line.index('\t')+1:].startswith(property_id):
    value = line[(line[:-1].rindex('\t')+1):]
    if is_date:
      value = str(time.strptime(value[:4], "%Y").tm_year)
    elif not line.endswith('\t'):
      continue
    if value in associated_entities:
      statement += "(9,'" + association_definition_id + "','" + str(entities[entity_id]) + "','" + str(associated_entities[value]) + "'),"
      num_entries += 1
      if (num_entries % 500 == 0): print("Entered 500 associations!")

print("Fetching entries done!")

utils.commit_sql(statement[:-1])

print("Entering entries done!")
