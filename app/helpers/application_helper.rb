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

  def toggle_visibility_if(condition, options={}, &block)
    condition ? toggle_visibility(options, &block) : capture(&block)
  end

  def toggle_block_if(condition, options={}, &block)
    condition ? toggle_block(options, &block) : capture(options[:show_not_visible] ? false : true , &block)
  end

  # OPTIONS
  # handle: The string to always use as handle.
  # toggle_handle: The string handle to swap once.
  # toggled_handle: The string handle to swap back once.
  # visible: Whether to show the visible part or the other.
  def toggle_block(options={}, &block)
    visible = options.has_key?(:visible) ? options[:visible] : true
    escapable = options.has_key?(:escapable) ? options[:escapable] : false
    out = "<span class='toggle_block'>"
    if options[:handle]
      out << "<span class='toggle_block_content'>#{capture(visible, &block)}</span>"
      out << "<span class='toggled_block_content' style='display: none;'>#{capture(!visible, &block)}</span>"
      out << handle_element(options[:handle])
    else
      if options[:toggle_handle]
        out << "<span class='toggle_block_content'>#{capture(visible, &block)}#{handle_element(options[:toggle_handle])}</span>"
      else
        out << "<span class='toggle_block_content toggle_block_handle'>#{capture(visible, &block)}</span>"
      end
      if options[:toggled_handle]
        out << "<span class='toggled_block_content' style='display: none;'>#{capture(!visible, &block)}#{handle_element(options[:toggled_handle])}</span>"
      else
        out << "<span class='toggled_block_content toggle_block_handle' style='display: none;'>#{capture(!visible, &block)}</span>"
      end
    end
    out << "</span>"
    raw out
  end

  def hover_block(*keys, &block)
    content_tag :span, keys.blank? ? {:class => "hover_block", :id => rand(1000)} : {:id => rand(1000), :class => "hover_block " + keys.join(' ')}, &block
  end

  def hover_hidden(key=nil, &block)
    options = {:style => "display: none;", :class => "hover_block_hidden"}
    options[:block_key] = key if key
    content_tag :span, options, &block
  end

  def toggle_visibility(options={}, &block)
    toggle_block({visible: false, escapable: false}.merge(options)) do |visible|
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
