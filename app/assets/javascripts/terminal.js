(function( $ ) {
  var methods = {
    ls : function( ) {
    },
    cd : function( ) { 
    }
  };

  $.fn.terminal = function( options ) {
    var settings = $.extend( {
      'font-color'              : 'light-green',
      'background-color'        : 'black'
    }, options);
    this.bind('keyup', function(event) {
      var value = $(this).attr('value');
      
    });
  };  
})( jQuery );

$(document).ready(function() {
  $('input[data-terminal]').terminal();
});
