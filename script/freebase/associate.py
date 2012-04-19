#!/usr/bin/python -O

# Scenario: For every movie, create associations for every performances.

import sys
import utils

# Command line arguments:
if len(sys.argv) != 4: raise RuntimeError("You must pass the association_definition_id, the property_id and the file name!")
association_definition_id = sys.argv[1]
property_id = sys.argv[2] # Ex: /film/film/starring
filename = sys.argv[3]

parent_id, associated_parent_id = utils.query_sql("SELECT entity_id,associated_entity_id FROM association_definitions WHERE id=" + association_definition_id)[0]

def get_entities_dict(parent_id):
  return dict(utils.query_sql("select freebase_id,id from entities where freebase_id IS NOT NULL and parent_id=" + str(parent_id)))

entities = get_entities_dict(parent_id)
associated_entities = get_entities_dict(associated_parent_id)

sys.stderr.write("Starting to fetch entries..")

statement="INSERT INTO associations (user_id,association_definition_id,entity_id,associated_entity_id) VALUES"
num_entries = 0
for line in open(filename, 'r'):
  line = line[:-1] # Strip the newline.
  entity_id = line[:line.index('\t')]
  if entity_id in entities and line.endswith('\t'):
    associated_entity_id = line[(line[:-1].rindex('\t')+1):-1]
    if line[line.index('\t')+1:].startswith(property_id) and associated_entity_id in associated_entities:
      import pdb; pdb.set_trace()
      statement += "(9,'" + association_definition_id + "','" + str(entities[entity_id]) + "','" + str(associated_entities[associated_entity_id]) + "'),"
      num_entries += 1
      if (num_entries % 500 == 0): sys.stderr.write("Entered 500 entities!")

sys.stderr.write("Fetching entries done!")

utils.commit_sql(statement[:-1])

sys.stderr.write("Entering entries done!")
