//= require livequery

$(document).ready(function() {
  $('.hover_block').livequery('mouseenter', function() {
    if (window.last_overed_element && window.last_overed_element == $(this)) {
      // Nothing to be done..
    } else if (window.last_overed_element) {
      toggleElements(window.last_overed_element.children('.hover_block_hidden').add(window.last_overed_element.find('[block_id="' + window.last_overed_element.attr('id') + '"]')));
    }
    toggleElements($(this).children('.hover_block_hidden').add($(this).find('[block_id="' + $(this).attr('id') + '"]')));
    window.last_overed_element = $(this);
  })
});
