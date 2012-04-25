#!/usr/bin/python -O

import utils

entities = {}
for ids in utils.query_sql("SELECT entity_id,associated_entity_id FROM associations"):
  entities[ids[0]] = entities.get(ids[0], 0) + 1
  entities[ids[1]] = entities.get(ids[1], 0) + 1

statement = "INSERT INTO entities (id,content_size_rank) VALUES "
for entity_id in entities:
  statement += "(" + str(entity_id) + "," + str(entities[entity_id]) + "),"

statement = statement[:-1] + " ON DUPLICATE KEY UPDATE content_size_rank=VALUES(content_size_rank)"

print("Commiting prepared statement..")

utils.commit_sql(statement)
