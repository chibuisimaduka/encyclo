$(function() {
  $(".pagination a").live("click", function() {
    $(this).parent().html("Page is loading...");
    $.getScript(this.href);
    return false;
  });
});
