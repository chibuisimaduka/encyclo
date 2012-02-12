//= require livequery

$(document).ready(function() {
  $('.hover_block').livequery('hover', function() {
    toggleElements($(this).children('.hover_block_hidden').add($(this).find('[block_id="' + $(this).attr('id') + '"]')));
  })
});
