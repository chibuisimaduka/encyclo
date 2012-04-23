from collections import defaultdict

class EntityAdviserIndex:
    
  # Entities are sorted by their rank.
  # FIXME: Commented because I don't know it it requires self and it should not.
  #def entities_sort(entity_id): return self.rank_by_entity[entity_id] 
  entities_sort = lambda entity_id: self.rank_by_entity[entity_id]

  # predicates_by_entity : Holds the predicates for every entity that have some.
  # rank_by_entity : Holds the rank for every entity.
  # associations_by_predicate : Holds (a hash of entities by their associated entity) for every predicate.
  def __init__(self):
    print("init")
    # Predicates for each entity are sorted by ascending number of values.
#    predicates_sort = lambda predicate: len(self.associations_by_predicate[predicate])
#    self.predicates_by_entity = defaultdict(sorted(key=predicates_sort))
#
#    self.rank_by_entity = dict(utils.query_sql("SELECT id,rank FROM entities"))
#
#    self.associations_by_predicate = defaultdict(defaultdict(sorted(list(), key=entities_sort)))
#
#    for predicate_attrs in utils.query_sql("SELECT id,entity_id,associated_entity_id FROM association_definitions"):
#      self.predicates_by_entity[predicate_attrs[1]] += [predicate_attrs[0]]
#      self.predicates_by_entity[predicate_attrs[2]] += [predicate_attrs[0]]
#
#      for association_attrs in utils.query_sql("""SELECT entity_id,associated_entity_id
#                            FROM associations WHERE definition_id = """ + predicate_attrs[0]):
#        self.associations_by_predicate[predicate_attrs[0]][association_attrs[0]] += association_attrs[1]
#        self.associations_by_predicate[predicate_attrs[0]][association_attrs[1]] += association_attrs[0]

  # LOGIC: Returns the top k entities matching...
  # | predicates == None   = the predicate that has the less values and it's value.
  # | len(predicates) == 1 = the predicate and it's value.
  # | otherwise            = the predicate that has the most values and it's value filtering by the other predicates.
  # PARAMS:
  # category_id = The parent_id of every entity returned.
  # limit = The number of records to return.
  # offset = A tuple of the entity id and rank of the last previously returned set. Or None.
  # predicates = A tuple of the predicate id and the id of it's value.
  def get_suggestions(self, category_id, limit, offset, predicates = None):
    suggestions = sorted(key=entities_sort)

    if predicates == None: # No filter
      predicate_id = self.predicates_by_entity[category_id][0]
      for associated_values in self.associations_by_predicate[predicate[0]]:
        suggestions = __filter_values(self, suggestions, assoiated_values, limit, offset)
    elif len(predicates) == 1: # One filter
      predicate = predicates[0]
      values = self.associations_by_predicate[predicate[0]][predicate[1]]
      suggestions = __filter_values(self, suggestions, values, limit, offset)
    else: # Many filters
      raise RuntimeError("TODO")

    return suggestions

  def add_association(self, association):
    raise RuntimeError("TODO")

  def update_entity_rank(self, entity_id, rank):
    self.rank_by_entity[entity_id] = rank

  # OPTIONS
  # suggestions = Modifies this list to hold the best suggestions.
  # values = A sorted list by rank of possible entity ids.
  # limit = The number of suggestions to be returned.
  # offset = A tuple holding the rank and id of the last entity of the last batch. Or None.
  def __filter_values(self, suggestions, values, limit, offset):
    for entity_id in values:
      rank = index.rank_by_entity[entity_id]
      if len(suggestions) < limit:
        if offset == None or (rank < offset[0] or (rank == offset[0] and entity_id < offset[1])):
          suggestions += v
      elif rank > index.rank_by_entity[suggestions[-1]]:
          suggestions += v
          suggestions.pop()
      else: break # Stop as soon as the rank is to low since values are sorted.
    return suggestions
