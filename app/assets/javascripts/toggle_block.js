//= require livequery

$(document).ready(function() {
  $('.toggle_block_handle').livequery('click', function() {
    toggleElements($(this).closest('.toggle_block').children('.toggle_block_content'));
    toggleElements($(this).closest('.toggle_block').children('.toggled_block_content'));
  })
});
