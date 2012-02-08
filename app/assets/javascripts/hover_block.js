$(document).ready(function() {
  $('.hover_block_key').hover(function() {
    toggleElements($(this).children('.hover_block_value'));
  })
  $('.hover_block_value').hide();
});
