$(document).ready(function() {
  $('.toggle_block_handle').click(function() {
    var content_elem = $(this).hasClass('toggle_block') ? $(this) : $(this).parent().find('.toggle_block_content');
    var current_content = content_elem.html();
    content_elem.html($(this).attr("data-toggled-content"));
    $(this).attr("data-toggled-content", current_content);
  })
});
