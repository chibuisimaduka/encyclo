from adviser.ttypes import *

import utils

from blist import sortedlist

class EntityAdviserIndex:
    
  # Entities are sorted by their rank.
  def entities_sort(self, entity_id): return (self.rank_by_entity[entity_id] or 0.0) * -1
  
  def __init__(self):

    self.rank_by_entity = dict()
    self.entities_by_category = dict()

    for category_attrs in utils.query_sql("SELECT id FROM entities WHERE id IN (SELECT DISTINCT parent_id from entities)"):
      entities = dict(utils.query_sql("SELECT id,rank FROM entities WHERE parent_id = " + str(category_attrs[0])))
      self.rank_by_entity.update(entities)
      self.entities_by_category[category_attrs[0]] = sortedlist(entities.keys(), key=self.entities_sort)

  # PARAMS:
  # category_id = The parent_id of every entity returned.
  # limit = The number of records to return.
  # offset = A tuple of the entity id and rank of the last previously returned set. Or 0.
  # predicates = A tuple of the predicate id and the id of it's value.
  # TODO: Filter if it's alive of dead.
  def get_suggestions(self, category_id, limit, offset, predicates = None):
    entities_ids = None
    matches_count = 0

    if predicates == None or len(predicates) == 0: # No filter
      if self.entities_by_category.has_key(category_id):
        entities = self.entities_by_category[category_id]
        entities_ids = entities[offset:offset+limit]
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

    return Suggestions(entities_ids, matches_count)

  def __ids_statement(self, predicate):
    direct_statement = self.__filter_statement("entity_id", predicate.definition_id, "associated_entity_id = " + str(predicate.entity_id))
    indirect_statement = self.__filter_statement("associated_entity_id", predicate.definition_id, "entity_id = " + str(predicate.entity_id))
    return "(" + direct_statement + ") UNION ALL (" + indirect_statement + ")"

  def __filter_statement(self, select_field, definition_id, where_clause):
    return "SELECT "+ select_field +",rank FROM associations WHERE association_definition_id = "+ str(definition_id) + " and " + where_clause

  def update_entity_rank(self, entity_id, rank, category_id):
    self.entities_by_category[category_id].remove(entity_id)
    self.rank_by_entity[entity_id] = rank
    self.entities_by_category[category_id].add(entity_id)

  def __rank_by_entity(self, category_id):
    return self.rankings_by_entity[category_id]
