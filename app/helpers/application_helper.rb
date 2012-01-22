module ApplicationHelper

  # Options are :
  # limit: The number of records shown before "show_more_results" link, default 1.
  def show_limited_results(records, options={}, &block)
    html = ""
    num_records_shown = options[:limit] || 1
    for record in records[0..(num_records_shown-1)]
      html << content_tag_for(:div, record, class: options[:class]) do
        yield(record)
      end
    end
	 if records.size > num_records_shown
	   html << toggle_each_visibility("See more #{records.first.class.to_s.downcase.pluralize}..", records[num_records_shown..-1], &block)
    end
    html.html_safe
  end

  def toggle_each_visibility(name, list, &block)
    html = ""
    for record in list
      html << content_tag_for(:div, record, :class => "#{list.first.id}_limited", :style => "display: none;") do
        yield(record)
      end
    end
	 html << content_tag(:span, :class => "#{name}_link") do
      link_to_function name, "toggle_visibility_for('#{list.first.class.to_s.downcase} #{list.first.id}_limited');"
	 end
    html
  end

  def toggle_visibility(name, &block)
    content_tag(:span, :id => name, :style => "display: none;", &block) +
	 content_tag(:span, :class => "#{name}_link") do
      link_to_function name, "toggle_visibility('#{name}');"
	 end
  end

  def rankable_list(entity, records, options={}, &block)
    render :partial => "entities/rankable_list", :locals => {:entity => entity, :records => records, :block => block}.merge(options)
  end

  def trunk_entities
    # FIXME: TMP: ["movie", "world", "tutorial", "recipee", "book", "person"].collect {|name| Entity.find_by_name(name) }
  end
  
end
