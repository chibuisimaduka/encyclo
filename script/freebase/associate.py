#!/usr/bin/python -O

# Scenario: For every movie, create associations for every performances.

import sys

# Command line arguments:
if len(sys.argv) != 3: raise RuntimeError("You must pass the association_definition_id and the file name!")
association_definition_id = sys.argv[1]
filename = sys.argv[2]

def extract_association_definition_attrs():
  return utils.query_sql("SELECT entity_id,associated_entity_id FROM association_definitions WHERE id=" + association_definition_id)

parent_id, asociated_parent_id = extract_association_definition_attrs

def get_entities_dict(parent_id):
  return dict(utis.query_sql("select freebase_id,id from entities where freebase_id IS NOT NULL and parent_id=" + parent_id))

entities = get_entities_dict(parent_id)
associated_entities = get_entities_dict(associated_parent_id)

sys.stderr.write("Starting to fetch entries..")

statement="INSERT INTO associations (user_id,association_definition_id,entity_id,associated_entity_id) VALUES"
num_entries = 0
for line in open(filename, 'r'):
  entity_id = line[:line.index('\t')]
  if (entity_id in entities && line.endswith('\t'))
    associated_entity_id = line[line[:-1].rindex('\t'):]
    if (associated_entity_id in associated_entities)
      statement += "(9,'" + association_definition_id + "','" + str(entities[entity_id]) + "','" + str(associated_entities[associated_entity_id]) + "'),"
      num_entries += 1
      if (num_entries % 100 == 0): sys.stderr.write("Entered 100 entities!")

sys.stderr.write("Fetching entries done!")

utils.commit_sql(statement[:-1])

sys.stderr.write("Entering entries done!")
