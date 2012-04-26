import sys

from adviser.ttypes import *

import utils

from collections import defaultdict

from blist import sortedlist

# TODO:
#from bisect import insort
#items = [1,5,7,9]
#insort(items, 10)

class EntityAdviserIndex:
    
  # Entities are sorted by their rank.
  def entities_sort(self, entity_id): return (self.rank_by_entity[entity_id] or 0.0) * -1
  
  def __init__(self):

    self.rank_by_entity = dict()
    self.entities_by_category = dict()

    for category_attrs in utils.query_sql("SELECT id FROM entities WHERE id IN (SELECT DISTINCT parent_id from entities)"):
      entities = dict(utils.query_sql("SELECT id,rank FROM entities WHERE parent_id = " + str(category_attrs[0])))
      self.rank_by_entity.update(entities)
      #self.entities_by_category[category_attrs[0]] = sortedlist(entities.keys(), key=lambda entity_id: self.rank_by_entity[entity_id] or 0.0)
      self.entities_by_category[category_attrs[0]] = sortedlist(entities.keys(), key=self.entities_sort)

    self.associations_by_predicate = defaultdict(lambda: defaultdict(lambda: sortedlist(key=self.entities_sort)))

    "SELECT id FROM entities INNER JOIN associations ON associations.entity_id = entities.id ORDER BY rank DESC limit 20;"
    for predicate_attrs in utils.query_sql("SELECT id FROM association_definitions"):
      for association_attrs in utils.query_sql("""SELECT entity_id,associated_entity_id FROM associations
                                                  WHERE association_definition_id = """ + str(predicate_attrs[0])):
        entities = self.associations_by_predicate[predicate_attrs[0]][association_attrs[0]]
        entities.add(association_attrs[1])
        if entities.size > 20: entities.pop
        entities = self.associations_by_predicate[predicate_attrs[0]][association_attrs[1]]
        entities.add(association_attrs[0])
        if entities.size > 20: entities.pop

  # LOGIC: Returns the top k entities matching...
  # | predicates == None   = the predicate that has the less values and it's value.
  # | len(predicates) == 1 = the predicate and it's value.
  # | otherwise            = the predicate that has the most values and it's value filtering by the other predicates.
  # PARAMS:
  # category_id = The parent_id of every entity returned.
  # limit = The number of records to return.
  # offset = A tuple of the entity id and rank of the last previously returned set. Or 0.
  # predicates = A tuple of the predicate id and the id of it's value.
  # TODO: Filter if it's alive of dead.
  def get_suggestions(self, category_id, limit, offset, predicates = None):
    entities_ids = sortedlist(key=self.entities_sort)
    matches_count = 0

    if predicates == None or len(predicates) == 0: # No filter
      if self.entities_by_category.has_key(category_id):
        entities = self.entities_by_category[category_id]
        entities_ids = entities[offset:offset+limit]
        matches_count = len(entities)
    elif len(predicates) == 1: # One filter
      values = self.associations_by_predicate[predicates[0][0]][predicates[0][1]]
      entities_ids = __filter_values(self, entities_ids, values, limit, offset)
    else: # Many filters
      raise RuntimeError("TODO")

    return Suggestions(entities_ids, matches_count)

  def add_association(self, association):
    raise RuntimeError("TODO")

  def update_entity_rank(self, entity_id, rank, category_id):
    self.entities_by_category[category_id].remove(entity_id)
    self.rank_by_entity[entity_id] = rank
    self.entities_by_category[category_id].add(entity_id)

  def __rank_by_entity(self, category_id):
    return self.rankings_by_entity[category_id]

  # OPTIONS
  # suggestions = Modifies this list to hold the best suggestions.
  # values = A sorted list by rank of possible entity ids.
  # limit = The number of suggestions to be returned.
  # offset = A tuple holding the rank and id of the last entity of the last batch. Or 0.
  def __filter_values(self, category_id, suggestions, values, limit, offset):
    for entity_id in values:
      rank = self.rankings_by_entity[category_id][entity_id]
      if len(suggestions) < limit:
        if offset == 0 or (rank < offset[0] or (rank == offset[0] and entity_id < offset[1])):
          suggestions += v
      elif rank > self.rankings_by_entity[category_id][suggestions[-1]]:
          suggestions += v
          suggestions.pop()
      else: break # Stop as soon as the rank is to low since values are sorted.
    return suggestions
