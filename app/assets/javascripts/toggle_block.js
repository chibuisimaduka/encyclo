$(document).ready(function() {
  $('.toggle_block_handle').click(function() {
    toggleElements($(this).closest('.toggle_block').children('.toggle_block_content'));
    toggleElements($(this).closest('.toggle_block').children('.toggled_block_content'));
  })
  $('.toggled_block_content').hide();
});

// The .toggle() method does not work in chrome.
function toggleElements(elements) {
  var elem = elements[0];
  if(elem.style.display == 'none')
    elements.show();
  else
    elements.hide();                       
}
