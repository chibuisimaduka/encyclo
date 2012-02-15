//= require livequery

$(document).ready(function() {
  $('.hover_block').livequery('mouseenter', function() {
    if (window.last_overed_element && window.last_overed_element == $(this)) {
      // Nothing to be done..
    } else {
      if (window.last_overed_element) {
        toggleHoverElement(window.last_overed_element);
      }
      toggleHoverElement($(this));
      window.last_overed_element = $(this);
    }
  })
});

function toggleHoverElement(hoverElement) {
  var classes = hoverElement.attr('class').split(' ').slice(1);
  var elements = hoverElement.children('.hover_block_hidden');
  for (var i in classes) {
    elements = elements.add(hoverElement.find('[block_key="' + classes[i] + '"]'));
  }
  toggleElements(elements);
}
