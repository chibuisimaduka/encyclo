$(document).ready(function() {
  $('.add_association_link').click(function() {
    $('#association_definition_'.concat(jQuery(this).attr("data-definition-id"))).append(jQuery(this).attr("data-form-content"));
  })
});
