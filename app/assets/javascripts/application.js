// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require jquery.purr
//= require autocomplete-rails
//= require best_in_place
//= require_tree .

$(document).ready(function() {
  $('#search_entity_name_field').focus();
})

function toggle_visibility(id) {
  var e = document.getElementById(id);
  if(e.style.display == 'block')
    e.style.display = 'none';
  else
    e.style.display = 'block';
}

function toggle_visibility_for(className) {
  var e = document.getElementsByClassName(className);
  for ( var i=0, len=e.length; i<len; ++i ){
    if(e[i].style.display == 'block')
      e[i].style.display = 'none';
    else
      e[i].style.display = 'block';
  }
}
