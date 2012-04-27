module EntitiesHelper

  # Returns all the associations for the given entity grouped by their definition.
  def associations_by_definition(entity, entities)
    #((entities.length == 0 ? entity.ancestors + [entity] : entity.ancestors)
    definitions = ((entity.ancestors + [entity]).flat_map {|e| e.all_association_definitions(current_user) }).to_set
    associations_for_definitions(entity, definitions)
  end

  def associations_for_definitions(entity, definitions)
    Hash[definitions.map do |d|
      direct = Association.where("association_definition_id = ? and entity_id = ?", d.id, entity.id)
      indirect = Association.where("association_definition_id = ? and associated_entity_id = ?", d.id, entity.id)
      statement = "(#{direct.to_sql}) UNION ALL (#{indirect.to_sql}) ORDER BY rank DESC"
      records = Association.paginate_by_sql(statement, page: params[:association_page])
      # OPTIMIZE: Find a better way to do this.
      records = WillPaginate::Collection.create(params[:association_page] || 1, Association.per_page, records.total_entries) do |pager|
        pager.replace records.map {|a| a.entity_id == entity.id ? a : ReversedAssociation.new(a) }
      end
      [d, records]
    end]
  end

  def features_for_associations(associations, entity, definition)
    features = associations.map(&:associated_entity)
    if definition.nested_entity
      features |= nested_features(entity, definition.nested_entity, definition.associated_entity) 
    end
    features
  end

  # Returns the association entities through a given nested entity.
  def nested_features(entity, nested_entity, associated_entity)
    entities = nested_entities_for(entity, nested_entity)
    (entities.map {|e| nested_entities_for(e, associated_entity) }).flatten
  end

  def nested_entities_for(entity, nested_entity)
    if ((nested_def = definition_for(entity, nested_entity)) && (nested_nested_entity = nested_def.nested_entity))
       (nested_entities_for(entity, nested_nested_entity).map {|e| nested_entities_for(e, nested_entity) }).flatten
    else
      associations = entity.associations.joins(:definition).where("association_definitions.associated_entity_id = ?", nested_entity.id)
      (!associations.blank?) ? associations.map(&:associated_entity) :
        entity.associated_associations.joins(:definition).where("association_definitions.entity_id = ?", nested_entity.id).map(&:entity)
    end
  end

  def definition_for(entity, nested_entity)
    (entity.map_all :parent, lambda {|e| e.all_association_definitions(current_user) }).select {|a| a.associated_entity_id == nested_entity.id }
  end

  def link_to_entity(entity)
    link_to entity.name(current_user, current_language), entity
    #link_to entity_name(entity), entity, remote: true, format: :js
  end

  def filter_value_id(definition, filters)
    definition_id = definition.id.to_s
    filters && filters[definition_id] && !filters[definition_id]["name"].blank? ? filters[definition_id]["id"] : ''
  end

  def filter_value_name(definition, filters)
    filters && filters[definition.id.to_s] ? filters[definition.id.to_s]["name"] : ''
  end
end
