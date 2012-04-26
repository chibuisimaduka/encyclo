#!/usr/bin/python -O

import utils

parent_by_entity = dict(utils.query_sql("SELECT id,parent_id FROM entities"))

statement = "INSERT INTO entities_ancestors (entity_id,ancestor_id) VALUES "
for entity_id in parent_by_entity:
  parent_id = parent_by_entity[entity_id]
  while parent_id != None:
    statement += "(" + str(entity_id) + "," + str(parent_id) + "),"
    parent_id = parent_by_entity[parent_id]

print("Truncating entities ancestors..")
# FIXME: Something less radical.
utils.commit_sql("TRUNCATE TABLE entities_ancestors;")
print("Inserting the new values..")
utils.commit_sql(statement[:-1])
