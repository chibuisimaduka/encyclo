#!/usr/bin/python -O

print("INFO: set_content_size_rank should be run first.")

import utils
from collections import defaultdict

# The rank is normalized from 0 to 1.
# The rank is calculated using a Bayesian estimate mean of the user ratings.
# If there is no ratings yet, it uses a normalized content_size_rank limited to 0.5.
#
# Bayesian mean estimate:
# W = (Rv + Cm) / (v + m)
# where R = average rating, v = number of ratings, C = overall average rating, m = minimum of votes required
statement = "INSERT INTO entities (id,rank) VALUES "
for category_attrs in utils.query_sql("SELECT id FROM entities WHERE id IN (SELECT DISTINCT parent_id FROM entities)"):

  ratings_by_entity = dict()
  for rating_attrs in (utils.query_sql("""SELECT entities.id,ratings.value FROM ratings
                                          INNER JOIN entities ON ratings.rankable_id = entities.id AND rankable_type = 'Entity'
                                          WHERE entities.parent_id = """ + str(category_attrs[0]))):
    if ratings_by_entity.has_key(rating_attrs[0]):
      ratings_by_entity[rating_attrs[0]] += [rating_attrs[1]]
    else: ratings_by_entity[rating_attrs[0]] = [rating_attrs[1]]

  max_content_rank = utils.query_sql("SELECT MAX(content_size_rank) FROM entities WHERE parent_id = " + str(category_attrs[0]))[0][0]
  if max_content_rank != None: content_size_rank_norm = 1 / (max_content_rank * 2)
  ratings_rank_norm = 1.0 / 10.0

  if len(ratings_by_entity) > 0:
    min_votes = 1
    # We can't keep track of the real overall mean, because it would mean
    # that if we change a rating, all the other ranks should change as well.
    mean = 7.0
  for entity_attrs in utils.query_sql("SELECT id,content_size_rank FROM entities WHERE parent_id = " + str(category_attrs[0])):
    if ratings_by_entity.has_key(entity_attrs[0]):
      ratings = ratings_by_entity[entity_attrs[0]]
      ratings_score = (sum(ratings) + (mean * min_votes)) / (len(ratings) + min_votes)
      statement += "("+ str(entity_attrs[0]) + ","+ str(ratings_score * ratings_rank_norm) +"),"
    else:
      # content_score = (e.all_associations.map {|a| a.associated_entity.content_size_rank}).sum
      if entity_attrs[1] != None: statement += "("+ str(entity_attrs[0]) + ","+ str(entity_attrs[1] * content_size_rank_norm) +"),"

statement = statement[:-1] # Strip the extra comma
statement += " ON DUPLICATE KEY UPDATE rank=VALUES(rank);"
  
print("Calculating rankings done!")
utils.commit_sql(statement)
print("Entering rankings done!")
