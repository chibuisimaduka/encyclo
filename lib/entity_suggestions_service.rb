class EntitySuggestionsService

  private_class_method :new
           
  @@instance = EntitySimilarityMatrix.new
              
  def self.instance
    return @@instance
  end

  # The datastructure of the index is as follow:
  # {:category => {:predicate => {:associated_entity_id => [sorted_list_of_entities]}}}
  # The predicates are sorted by their number of values for two reasons:
  #   1. Pick the one that has the less when none is asked.
  #   2. Pick the one that has the most when many are choosen.
  # The entities are sorted by their rank $ and id because it's a set.

  def init(users, entities, ratings)
    @categories = {}
    # Build a matrix for every category.
    Entity.includes(:entities => :associations).where("id IN (SELECT DISTINCT(parent_id) FROM entities)").each do |entity|
      category = SortedHash.new()
      entity.entities.each do |e|
        e.all_associations.each do |a|
          predicate = category[a.definition_id] # TODO: Or add
          predicate_value = predicate[a.associted_entity_id]
          predicate[a.associted_entity_id] = predicate_value ? SortedSet.new(e) : predicate_value << e
        end
      end
      @categories[entity.id] = category
    end
  end

  def update_entity(old_entity, entity)
    if entity.parent_id
      category = @categories[entity.parent_id]
      category[category.index(old_entity)] = entity
    end
  end

  def get_suggestions(category_id, limit, offset, predicates=nil)
    return get_suggestions_with_many_predicates(category_id, limit, offset, predicates) if predicates && predicates.size > 1
  
    top_values = SortedSet.new()
    predicate_vals = predicates.blank? @categories[category_id].first :
                                       @categories[category_id][predicates.first.id]
    predicate_vals.each do |association,values|
      top_values = get_top_values(top_values, values)
    end
    top_values
  end

private

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
        end
      end
    end
    top_values
  end

  def get_suggestions_with_many_predicates(category_id, limit, offset, predicates)
    raise "TODO"
  end
 
end
