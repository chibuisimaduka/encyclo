#!/usr/bin/python -O

print("INFO: set_content_size_rank should be run first.")

import utils
from collections import defaultdict

# The rank is calculated using a combination of user ratings and content rank.
# The ratings rank is calculated using a Bayesian estimate mean.
statement = "INSERT INTO entities (id,rank) VALUES "
for category_attrs in utils.query_sql("SELECT id FROM entities WHERE id IN (SELECT DISTINCT parent_id FROM entities)"):

  ratings_by_entity = dict()
  for rating_attrs in (utils.query_sql("""SELECT entities.id,ratings.value FROM ratings
                                          INNER JOIN entities ON ratings.rankable_id = entities.id AND rankable_type = 'Entity'
                                          WHERE entities.parent_id = """ + str(category_attrs[0]))):
    if ratings_by_entity.has_key(rating_attrs[0]):
      ratings_by_entity[rating_attrs[0]] += [rating_attrs[1]]
    else: ratings_by_entity[rating_attrs[0]] = [rating_attrs[1]]

  ratings_sum = sum(map(sum, ratings_by_entity.values()))
  ratings_count = sum(map(lambda entity: len(ratings_by_entity[entity]), ratings_by_entity))
  valid_probability = 0.4

  if ratings_count > 0:
    min_votes = 1
    mean = ratings_sum / ratings_count
  for entity_attrs in utils.query_sql("SELECT id,content_size_rank FROM entities WHERE parent_id = " + str(category_attrs[0])):
    if ratings_by_entity.has_key(entity_attrs[0]):
      ratings = ratings_by_entity[entity_attrs[0]]
      ratings_score = (sum(ratings) + (mean * min_votes)) / (len(ratings) + min_votes)
      statement += "("+ str(entity_attrs[0]) + ","+ str(ratings_score * 10000) +"),"
    else:
      # content_score = (e.all_associations.map {|a| a.associated_entity.content_size_rank}).sum
      if entity_attrs[1] != None: statement += "("+ str(entity_attrs[0]) + ","+ str(entity_attrs[1]) +"),"

statement = statement[:-1] # Strip the extra comma
statement += " ON DUPLICATE KEY UPDATE rank=VALUES(rank);"
  
print("Calculating rankings done!")
utils.commit_sql(statement)
print("Entering rankings done!")
