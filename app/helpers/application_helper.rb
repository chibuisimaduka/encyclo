module ApplicationHelper

  def show_more_records(records, options={}, &block)
    if options[:limit] && records.size > options[:limit].to_i
      toggle_block({handle: "Show more records.."}.merge(options)) do |is_not_more|
        (records[is_not_more ? 0..(options[:limit]-1) : options[:limit]..-1].map {|r| capture(r, !is_not_more, &block) }).join.html_safe
      end
    else
      raw (records.map {|r| capture(r, false, &block) }).join
    end
  end

  def toggle_block(options={}, &block)
    visible = options.has_key?(:visible) ? options[:visible] : true
    out = "<span class='toggle_block'>"
    out << "<span class='toggle_block_content#{options[:handle] ? "" : " toggle_block_handle"}'>#{capture(visible, &block)}</span>"
    out << "<span class='toggled_block_content'>#{capture(!visible, &block)}</span>"
    out << "<span class='toggle_block_handle'>#{options[:handle]}</span>" if options[:handle]
    out << "</span>"
    raw out
  end

  def toggle_visibility(options={}, &block)
    toggle_block({visible: false}.merge(options)) do |visible|
      visible ? capture(&block) : ""
    end
  end

  def rankable_list(entity, records, options={}, &block)
    render :partial => "entities/rankable_list", :locals => {:entity => entity, :records => records, :block => block}.merge(options)
  end

  def link_to_insert(name, content, selector)
    out = "<span class='link_to_insert'"
    out << " data-selector='#{selector}'"
    out << " data-content='#{content}'"
    out << ">#{name}</span>"
    raw out
  end

  def best_in_place_filter(filter, method, collection, session_key, options={})
    best_in_place filter, method, {type: :select, collection: collection, path: {controller: "sessions", action: "update", value_key: "filterer", session_key: session_key, id: "fixme"}}.merge(options)
  end

end
