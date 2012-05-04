struct PredicateEntry {
  1: i32 definition_id
  2: i32 entity_id
}

struct Suggestions {
  1: list<i32> entities_ids
  2: i32 matches_count
}

service EntityAdviser {

  bool ping()

  Suggestions get_suggestions(1:i32 user_id, 2:i32 category_id, 3:i32 limit, 4:i32 offset, 5:list<PredicateEntry> predicate_ids)

  void update_entity_rank(1:i32 entity_id, 2:double rank, 3:i32 category_id, 4:i32 user_id, 5:double user_rating)
}
