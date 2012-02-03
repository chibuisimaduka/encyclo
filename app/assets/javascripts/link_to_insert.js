$(document).ready(function() {
  $('.link_to_insert').click(function() {
    $($(this).attr("data-selector")).append($(this).attr("data-content"));
  })
});
