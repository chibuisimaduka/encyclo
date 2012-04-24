import sys
sys.path.append('../../../../script/freebase/') # FIXME: Ugly as hell

from adviser.ttypes import *

import utils

from collections import defaultdict
from collections import OrderedDict

class EntityAdviserIndex:
    
  # Entities are sorted by their rank.
  def entities_sort(self, entity_id):
    # !!!FIXME!!! Real awful way to get the raking..
    for rankings in rankings_by_entity.values():
      if rankings.has_key(entity_id): return rankings[entity_id]
  
  def entities_tuple_sort(self, entity_attrs): return entity_attrs[1] or 0

  # predicates_by_entity : Holds the predicates for every entity that have some.
  # rankings_by_entity : Holds rank_by_entity for every category.
  # rank_by_entity : Holds the rank for every entity.
  # associations_by_predicate : Holds (a hash of entities by their associated entity) for every predicate.
  def __init__(self):
    # Predicates for each entity are sorted by ascending number of values.
    predicates_sort = lambda predicate: len(self.associations_by_predicate[predicate])
    self.predicates_by_entity = defaultdict(lambda: sorted(list(), key=predicates_sort))

    self.rankings_by_entity = dict()
    for category_attrs in utils.query_sql("SELECT id FROM entities WHERE id IN (SELECT DISTINCT parent_id from entities)"):
      statement = "SELECT id,rank FROM entities WHERE parent_id = " + str(category_attrs[0])
      self.rankings_by_entity[category_attrs[0]] = OrderedDict(sorted(utils.query_sql(statement), key=self.entities_tuple_sort, reverse=True))

    self.associations_by_predicate = defaultdict(lambda: defaultdict(lambda: sorted(list(), key=self.entities_sort, reverse=True)))

    for predicate_attrs in utils.query_sql("SELECT id,entity_id,associated_entity_id FROM association_definitions"):
      self.predicates_by_entity[predicate_attrs[1]] += [predicate_attrs[0]]
      self.predicates_by_entity[predicate_attrs[2]] += [predicate_attrs[0]]

      for association_attrs in utils.query_sql("""SELECT entity_id,associated_entity_id FROM associations
                                                  WHERE association_definition_id = """ + str(predicate_attrs[0])):
        self.associations_by_predicate[predicate_attrs[0]][association_attrs[0]] += [association_attrs[1]]
        self.associations_by_predicate[predicate_attrs[0]][association_attrs[1]] += [association_attrs[0]]

  # LOGIC: Returns the top k entities matching...
  # | predicates == None   = the predicate that has the less values and it's value.
  # | len(predicates) == 1 = the predicate and it's value.
  # | otherwise            = the predicate that has the most values and it's value filtering by the other predicates.
  # PARAMS:
  # category_id = The parent_id of every entity returned.
  # limit = The number of records to return.
  # offset = A tuple of the entity id and rank of the last previously returned set. Or 0.
  # predicates = A tuple of the predicate id and the id of it's value.
  def get_suggestions(self, category_id, limit, offset, predicates = None):
    entities_ids = sorted(list(), key=self.entities_sort, reverse=True)

    if predicates == None or len(predicates) == 0: # No filter
      offset_index = self.rankings_by_entity[category_id].index(offset[0]) if offset != 0 else 0
      # TODO: Filter if it's alive of dead.
      # FIXME: Does this fetch all values? Not a good idea if so..
      if self.rankings_by_entity.has_key(category_id):
        entities_ids = self.rankings_by_entity[category_id].keys()[offset_index:offset_index+limit]
        matches_count = len(self.rankings_by_entity[category_id].keys())
    elif len(predicates) == 1: # One filter
      values = self.associations_by_predicate[predicates[0][0]][predicates[0][1]]
      entities_ids = __filter_values(self, entities_ids, values, limit, offset)
    else: # Many filters
      raise RuntimeError("TODO")

    return Suggestions(entities_ids, matches_count)

  def add_association(self, association):
    raise RuntimeError("TODO")

  def update_entity_rank(self, entity_id, rank):
    raise RuntimeError("FIXME")
    #self.rank_by_entity[entity_id] = rank # FIXME: Change the order. FIXME: Does not have category

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
