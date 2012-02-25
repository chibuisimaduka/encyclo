function term_err(msg) {
  $('#terminal_output').html(msg).css('color', 'red')
}

function term_out(msg) {
  $('#terminal_output').html(msg)
}

// Assumes that commands is a set with more that one element,
// all starting with partial_command.
function longest_common_chars(partial_command, commands) {
  for (var i=partial_command.length;;i++) {
    var common_char;
    for (var command_i in commands) {
      var command = commands[command_i];
      if (command.length == i) {
        return command.slice(0,i);
      } else {
        if (!common_char) {
          common_char = command[i]
        } else if (command[i] != common_char) {
          return command.slice(0,i);
        }
      }
    }
  }
}

(function( $ ) {
  var commands = {
    help : function( args ) {
      term_out(Object.keys(commands).join(' '));
    }, ls : function( args ) {
      alert('ls');
    },
    login : function( args ) {
      alert('login');
    },
    logout : function( args ) {
      alert('logout');
    },
    mv : function( args ) {
      alert('mv');
    },
    cd : function( args ) { 
      alert('cd');
    }
  };

  $.fn.terminal = function( options ) {

    var settings = $.extend( {
      'font-color'              : 'light-green',
      'background-color'        : 'black'
    }, options);

    this.bind('keyup', function(event) {
      var command_parts = $(this).attr('value').split(' ');
      var command = command_parts[0];
      if ( event.which == 13) { // Execute on ENTER.
        if ( commands[command] ) {
          commands[command](command_parts.slice(1));
        } else {
          term_err('Command ' + command + ' does not exist.');
        }
      } else if ( event.which == 9 ) { // Autocomplete on TAB.
        if ( command_parts.length == 1 ) {
          var possible_commands = new Array();
          for (var command_name in commands) {
            if (command == command_name.slice(0,command.length)) {
              possible_commands.push(command_name);
            }
          }
          if (possible_commands.length == 1) {
            $(this).attr('value', possible_commands[0] + ' ');
          } else if (possible_commands.length > 1) {
            $(this).attr('value', longest_common_chars(command, possible_commands));
            term_out(possible_commands.join(' '));
          }
        } else {
          // command_parts.last.
        }
        event.preventDefault();
        return false;
      } else if ( event.which == 27 ) { // Clear output on ESC.
        term_out('');
      }
    }).bind('keydown', function(event) {
      if (event.which == 9) {
        event.preventDefault();
        return false;
      }
    });
  };  
})( jQuery );

$(document).ready(function() {
  //$('input[data-terminal]').terminal();
  $('.terminal').terminal();
});
