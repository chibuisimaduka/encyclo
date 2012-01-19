module TagsHelper

  def refine_further(tag)
    parents = {}
	 tag.entities.each do |e|
	   e.tags.each do |t|
        parents[t.tag.id] = t.tag if t.tag
		end
	 end
    render partial: "tags/refine_further", locals: {tags: parents.collect(&:second)}
  end

  def tag_entity_path(tag, url_params)
    entity_path(url_params.merge(id: Entity.find_by_name(tag.name).id))
  end

end
