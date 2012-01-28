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
      more_message = options[:more_message] || "See more #{records.first.class.to_s.downcase.pluralize}.."
	   html << toggle_each_visibility(more_message, records[num_records_shown..-1], &block)
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

  def toggle_visibility(name, object=nil, options={}, &block)
    id = object ? "#{name}_#{object.class.name.downcase}_#{object.id}" : name
    content_tag(:span, :id => id, :style => "display: none;", &block) +
	 content_tag(:span, :class => "#{id}_link") do
      link_to_function name, "toggle_visibility('#{id}'#{options[:style] ? ", '#{options[:style]}'" : ''});"
	 end
  end

  def rankable_list(entity, records, options={}, &block)
    render :partial => "entities/rankable_list", :locals => {:entity => entity, :records => records, :block => block}.merge(options)
  end

end
