service EntityAdviser {

  list<i32> get_suggestions(1:i32 category_id, 2:i32 limit, 3:i32 offset)

  list<i32> get_filtered_suggestions(1:i32 category_id, 2:i32 limit, 3:i32 offset, 4:list<i32> predicate_ids)
}
