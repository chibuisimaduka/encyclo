$(function() {
  $(".pagination a").live("click", function() {
    $(this).parent().html("Page is loading...");
    // TODO: A hack that set the attributes on location.hash. For now, just reload the page.
    //$.getScript(this.href); 
    window.location.href = this.href; 
    return false;
  });
});
