struct PredicateEntry {
  1: i32 definition_id
  2: i32 entity_id
}

struct AssociationEntry {
  1: i32 definition_id
  2: i32 entity_id
  3: i32 associated_entity_id
}

service EntityAdviser {

  bool ping()

  list<i32> get_suggestions(1:i32 category_id, 2:i32 limit, 3:i32 offset, 4:list<PredicateEntry> predicate_ids)

  void add_association(1:AssociationEntry association)

  void update_entity_rank(1:i32 entity_id, 2:double rank)
}
