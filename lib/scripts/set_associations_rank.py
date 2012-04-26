#!/usr/bin/python -O

import utils

rank_by_entity = dict(utils.query_sql("SELECT id,rank FROM entities"))

statement = "INSERT INTO associations (id,rank) VALUES "
for ids in utils.query_sql("SELECT id,entity_id,associated_entity_id FROM associations"):
  import pdb; pdb.set_trace()
  statement += "(" + str(ids[0]) + "," + str(rank_by_entity[ids[1]] + rank_by_entity[ids[2]]) + "),"

statement = statement[:-1] + " ON DUPLICATE KEY UPDATE rank=VALUES(rank)"

print("Commiting prepared statement..")

utils.commit_sql(statement)
