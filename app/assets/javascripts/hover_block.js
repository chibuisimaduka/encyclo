//= require livequery

$(document).ready(function() {
  $('.hover_block').livequery('hover', function() {
    toggleElements($(this).children('.hover_block_hidden'));
  })
});
