// The .toggle() method does not work in chrome.
function toggleElements(elements) {
  var elem = elements[0];
  if(elem.style.display == 'none')
    elements.show();
  else
    elements.hide();                       
}
