from adviser.ttypes import *

import utils

from blist import sortedlist

class EntityAdviserIndex:
    
  # Entities are sorted by their rank.
  def entities_sort(self, entity_id): return (self.rank_by_entity[entity_id] or 0.0) * -1
  
  def __init__(self):

    self.rank_by_entity = dict()
    self.entities_by_category = dict()
    self.entities_ratings_by_user_by_category = dict()

    for category_attrs in utils.query_sql("SELECT id FROM entities WHERE id IN (SELECT DISTINCT parent_id from entities)"):
      entities = dict(utils.query_sql("SELECT id,rank FROM entities WHERE parent_id = " + str(category_attrs[0])))
      self.rank_by_entity.update(entities)
      self.entities_by_category[category_attrs[0]] = sortedlist(entities.keys(), key=self.entities_sort)
    
      entities_ratings_by_user = dict()
      for attrs in utils.query_sql("""SELECT ratings.user_id,entities.id,ratings.value FROM entities
          INNER JOIN ratings ON entities.id = ratings.rankable_id AND ratings.rankable_type = 'Entity'
          WHERE parent_id = """ + str(category_attrs[0])):
        if attrs[0] in entities_ratings_by_user:
          entities_ratings = entities_ratings_by_user[attrs[0]]
        else:
          entities_ratings = sortedlist(key=lambda (entity_id, rating): rating * (-1.0))
        entities_ratings.add((attrs[1], attrs[2]))
        entities_ratings_by_user[attrs[0]] = entities_ratings
      self.entities_ratings_by_user_by_category[category_attrs[0]] = entities_ratings_by_user

  # PARAMS:
  # category_id = The parent_id of every entity returned.
  # limit = The number of records to return.
  # offset = A tuple of the entity id and rank of the last previously returned set. Or 0.
  # predicates = A tuple of the predicate id and the id of it's value.
  # TODO: Filter if it's alive of dead.
  # FIXME: With filters, it does not consider inheritance. 
  # FIXME: Should be using the parent also because if the Asterix and Obelix serie is written by Uderzo and Gosciny, so is every of it's child.
  def get_suggestions(self, user_id, category_id, limit, offset, predicates = None):
    entities_ids = None
    matches_count = 0

    if predicates == None or len(predicates) == 0: # No filter
      if self.entities_by_category.has_key(category_id):
        entities = self.entities_by_category[category_id]
        entities_ratings_by_user = self.entities_ratings_by_user_by_category[category_id]
        user_entities = entities_ratings_by_user[user_id] if entities_ratings_by_user.has_key(user_id) else []
        entities_ids = self.__slice(entities, user_entities, limit, offset)
        matches_count = len(entities)
    elif len(predicates) == 1: # One filter
      ids_statement = self.__ids_statement(predicates[0])
      statement = ids_statement + " ORDER BY rank DESC LIMIT " + str(limit)
      if offset != None and offset != 0: statement += " OFFSET " + str(offset)

      matches_count = utils.query_sql("SELECT count(*) FROM (" + ids_statement + ") AS count_table")[0][0]
      entities_ids = map(utils.first, utils.query_sql(statement))
    else: # Many filters
      for predicate in predicates:
        ids = set(map(utils.first, utils.query_sql(self.__ids_statement(predicate))))
        entities_ids = ids if entities_ids == None else ids.intersect(entities_ids)

    return Suggestions(entities_ids or list(), matches_count)

  # Gives the slice of the list together without merging them because they could both be huge.
  # ranked_entities = list of entities ids
  # user_entities = list of tuples like (entity_id, rating_value)
  # [10,8,6,4,2] && [9,7,5,3,1] offset 4 limit 2 == [6,5] == start offsets (2,2)
  def __slice(self, ranked_entities, user_entities, limit, offset):
    # The first step is to first the starting offset of both lists.
    entities_ids = list()
    min_index = max(0, offset-limit)
    offsets = [min(min_index, max(0,len(ranked_entities)-1)), min(min_index, max(0,len(user_entities)-1))]
    while sum(offsets) != offset:
      if offsets[1]+1 < len(user_entities) and ranked_entities[offsets[0]] > user_entities[offsets[1]]:
        offsets[1] += 1
      else:
        offsets[0] += 1

    # Then, add elements one by one in order untill limit is reached.
    while len(entities_ids) < limit:
      if offsets[1]+1 < len(user_entities) and (offsets[0]+1 < len(ranked_entities) or
          user_entities[offsets[1]][1] > self.rank_by_entity[ranked_entities[offsets[0]]]):
        entities_ids.append(user_entities[offsets[1]][0])
        offsets[1] += 1
      elif offsets[0]+1 < len(ranked_entities):
        entities_ids.append(ranked_entities[offsets[0]])
        offsets[0] += 1
      else:
        break
    return entities_ids

  def __ids_statement(self, predicate):
    direct_statement = self.__filter_statement("entity_id", predicate.definition_id, "associated_entity_id = " + str(predicate.entity_id))
    indirect_statement = self.__filter_statement("associated_entity_id", predicate.definition_id, "entity_id = " + str(predicate.entity_id))
    return "(" + direct_statement + ") UNION ALL (" + indirect_statement + ")"

  def __filter_statement(self, select_field, definition_id, where_clause):
    return "SELECT "+ select_field +",rank FROM associations WHERE association_definition_id = "+ str(definition_id) + " and " + where_clause

  def update_entity_rank(self, entity_id, rank, category_id, user_id, user_rating):
    self.entities_by_category[category_id].remove(entity_id)
    self.rank_by_entity[entity_id] = rank
    self.entities_by_category[category_id].add(entity_id)
  
    entities_ratings = self.entities_ratings_by_user_by_category[category_id][user_id] 
    i = 0
    for entity_rating in entities_ratings:
      if entity_rating[0] == entity_id: break
      i += 1
    if i != len(entities_ratings): del entities_ratings[i]
    entities_ratings.add((entity_id, user_rating))

  def __rank_by_entity(self, category_id):
    return self.rankings_by_entity[category_id]
