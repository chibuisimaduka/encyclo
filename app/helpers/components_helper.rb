module ComponentsHelper

  def create_component_value_link(entity, component, name)
    if component.is_entity
      path = entities_path(entity: {:parent_id => entity.id, :component_id => component.id}, name: name.value, show: true)
    else
      path = user_documents_path(entity_id: entity.id, document: {name: name, component_id: component.id})
    end
    link_to name, path, method: :post
  end

  def associated_value_name(component, associated_value, user, language)
    component.is_entity? ? associated_value.name(user, language) : associated_value.name
  end

end
