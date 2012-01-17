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

end
