$(document).ready(function() {
  $('.hover_block').hover(function() {
    toggleElements($(this).children('.hover_block_hidden'));
  })
});
