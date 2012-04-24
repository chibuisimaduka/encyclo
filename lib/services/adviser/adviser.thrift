namespace rb entity_adviser

struct Predicate {
  1: i32 definition_id
  2: i32 entity_id
}

struct Association {
  1: i32 definition_id
  2: i32 entity_id
  3: i32 associated_entity_id
}

service EntityAdviser {

  bool ping()

  list<i32> get_suggestions(1:i32 category_id, 2:i32 limit, 3:i32 offset, 4:list<Predicate> predicate_ids)

  void add_association(1:Association association)

  void update_entity_rank(1:i32 entity_id, 2:double rank)
}
