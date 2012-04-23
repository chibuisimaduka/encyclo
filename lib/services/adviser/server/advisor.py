import utils

from collections import defaultdict

class EntityAdviserIndex:
    
  # Entities are sorted by their rank.
  # FIXME: Commented because I don't know it it requires self and it should not.
  #def entities_sort(entity_id): self.rank_by_entity[entity_id] 
  entities_sort = lambda entity_id: self.rank_by_entity[entity_id]

  # predicates_by_entity : Holds the predicates for every entity that have some.
  # rank_by_entity : Holds the rank for every entity.
  # associations_by_predicate : Holds (a hash of entities by their associated entity) for every predicate.
  def __init__(self):
    # Predicates for each entity are sorted by ascending number of values.
    predicates_sort = lambda predicate: len(self.associations_by_predicate[predicate])
    self.predicates_by_entity = defaultdict(sorted(key=predicates_sort))

    self.rank_by_entity = dict(utils.query_sql("SELECT id,rank FROM entities"))

    self.associations_by_predicate = defaultdict(defaultdict(sorted(list(), key=entities_sort)))

    for predicate_attrs in utils.query_sql("SELECT id,entity_id,associated_entity_id FROM association_definitions"):
      self.predicates_by_entity[predicate_attrs[1]] += [predicate_attrs[0]]
      self.predicates_by_entity[predicate_attrs[2]] += [predicate_attrs[0]]

      for association_attrs in utils.query_sql("""SELECT entity_id,associated_entity_id
                            FROM associations WHERE definition_id = """ + predicate_attrs[0]):
        self.associations_by_predicate[predicate_attrs[0]][association_attrs[0]] += association_attrs[1]
        self.associations_by_predicate[predicate_attrs[0]][association_attrs[1]] += association_attrs[0]

  def get_suggestions(self, category_id, limit, offset, predicates = None)
    suggestions = sorted(key=entities_sort)

    predicates_by_entity[category_id]

  def update_entity(): # FIXME...

def get_suggestions(category, limit, offset, predicates=nil)

  predicate_vals = predicates.blank? @categories[category_id].first :
                                     @categories[category_id][predicates.first.id]
  predicate_vals.each do |association,values|
    top_values = get_top_values(top_values, values)
  top_values

def get_top_values(top_values, values, limit, offset)
  values.each do |v|
    if top_values.length < limit
      if v.rank < offset.rank || (v.rank == offset.rank && v.id < offset.id)
        top_values += v
      end
    else
      if v.rank > top_values.last.rank
        top_values += v
        top_values.pop_last
      else
        break
  top_values

def get_suggestions_with_many_predicates(category_id, limit, offset, predicates)
  raise RuntimeError("TODO")
