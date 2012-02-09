module ApplicationHelper

  def show_more_records(records, options={}, &block)
    if options[:limit] && records.size > options[:limit].to_i
      toggle_block({handle: "Show more records..", toggled_handle: "Show less records.."}.merge(options)) do |is_not_more|
        (records[is_not_more ? 0..(options[:limit]-1) : 0..-1].map {|r| capture(r, !is_not_more, &block) }).join.html_safe
      end
    else
      raw (records.map {|r| capture(r, false, &block) }).join
    end
  end

  def toggle_block(options={}, &block)
    visible = options.has_key?(:visible) ? options[:visible] : true
    out = "<span class='toggle_block'>"
    if options[:handle] && options[:toggled_handle] 
      out << "<span class='toggle_block_content'>#{capture(visible, &block)}#{handle_element(options[:handle])}</span>"
      out << "<span class='toggled_block_content'>#{capture(!visible, &block)}#{handle_element(options[:toggled_handle])}</span>"
    else
      handle = options[:handle] || options[:toggled_handle]
      out << "<span class='toggle_block_content#{handle ? "" : " toggle_block_handle"}'>#{capture(visible, &block)}</span>"
      out << "<span class='toggled_block_content'>#{capture(!visible, &block)}</span>"
      out << handle_element(handle) if handle
    end
    out << "</span>"
    raw out
  end

  def hover_block(&block)
    content_tag :span, :class => "hover_block", &block
  end

  def hover_hidden(&block)
    content_tag :span, :class => "hover_block_hidden", &block
  end

  def toggle_visibility(options={}, &block)
    toggle_block({visible: false}.merge(options)) do |visible|
      visible ? capture(&block) : ""
    end
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

private
  def handle_element(handle)
    "<span class='toggle_block_handle'>#{handle}</span>"
  end

end
