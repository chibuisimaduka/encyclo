module EntitiesHelper

  # Returns all the associations for the given entity grouped by their definition.
  def associations_by_definition(entity, entities)
    associations_by_def = {}
    ((entities.length == 0 ? entity.ancestors + [entity] : entity.ancestors).flat_map {|e| e.all_association_definitions(current_user) }).each do |association_def|
      associations_by_def[association_def] = []
    end
    # Using the parent also because if the Asterix and Obelix serie is written by Uderzo and Gosciny, so is every of it's child.
    ((entity.ancestors + [entity]).flat_map {|e| e.all_associations(current_user) }).each do |association|
      associations_by_def[association.definition] = (associations_by_def[association.definition] || []) + [association]
    end
    associations_by_def.sort {|k,v| v.size }
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
