//= require livequery

$(document).ready(function() {
  $('.toggle_block_handle').livequery('click', function() {
    toggleElements($(this).closest('.toggle_block').children('.toggle_block_content'));
    toggleElements($(this).closest('.toggle_block').children('.toggled_block_content'));
  })
  // FIXME: Should instead keep track of the currently focused element?
  /* Giving up for now
  $('.toggle_block_handle').bind('keyup', function(event) {
    alert("keyup");
    if (event.keycode == 27) {
      var elements = $(this).closest('.toggle_block').children('.toggle_block_content');
      if (elements[0].is(":hidden")) {
        toggleElements(elements);
        toggleElements($(this).closest('.toggle_block').children('.toggled_block_content'));
      }
    }
  })
  */
});
