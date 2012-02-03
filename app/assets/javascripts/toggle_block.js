$(document).ready(function() {
  $('.toggle_block_handle').click(function() {
    $(this).parent().find('.toggle_block_content').toggle();
    $(this).parent().find('.toggled_block_content').toggle();
  })
});
