#!/usr/bin/python -O

# Scenario: For every movie, create associations for every performances.

import commands
import sys

# Command line arguments:
if len(sys.argv) != 3: raise RuntimeError("You must pass the association_definition_id and the file name!")
association_definition_id = sys.argv[1]
filename = sys.argv[2]

def extract_association_definition_attrs():
  return commands.getoutput('echo "select entity_id,associated_entity_id from association_definitions where id=' +
    association_definition_id + ';" | mysql -u root sorted_development').split('\n')

parent_id, asociated_parent_id = extract_association_definition_attrs

def get_entities_dict(parent_id):
  ids_str = commands.getoutput('echo "select freebase_id,id from entities where freebase_id IS NOT NULL and parent_id=' +
    parent_id + ';" | mysql -u root sorted_development')
  entities_dict = {}
  for both_ids_str in ids_str.split('\n')[1:]
    both_ids = id.split('\t')
    entities_dict[both_ids[0]] = both_ids[1]
  return entities_dict

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
      statement += "(9,'" + association_definition_id + "','" + entities[entity_id] + "','" + associated_entities[associated_entity_id] + "'),"
      num_entries += 1
      if (num_entries % 100 == 0): sys.stderr.write("Entered 100 entities!")
statement = statement[:-1] + ';'

sys.stderr.write("Fetching entries done!")

print(statement)

sys.stderr.write(commands.getoutput('echo "' + statement + '" | mysql -u root sorted_development'))

sys.stderr.write("Entering entries done!")
