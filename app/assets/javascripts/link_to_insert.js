$(document).ready(function() {
  $('.link_to_insert').click(function() {
    $(jQuery(this).attr("data-selector")).append(jQuery(this).attr("data-content"));
  })
});
