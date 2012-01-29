$(document).ready(function() {
  $('.add_entity_ref_link').click(function() {
    $('#component_'.concat(jQuery(this).attr("data-component-id"))).append(jQuery(this).attr("data-entity-ref-form"));
    $('.best_in_place').best_in_place();
  })
});
