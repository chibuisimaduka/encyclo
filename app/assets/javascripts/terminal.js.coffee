term_err = (msg) -> $('#terminal_output').html(msg).css('color', 'red')
term_out = (msg) -> $('#terminal_output').html(msg).css('color', 'black')
term_in = (msg) -> return if msg != undefined then $('.terminal').attr('value', msg) else $('.terminal').attr('value')

# Assumes that commands is a set with elements,
# all starting with partial_command.
longest_common_chars = (partial_command, commands) ->
  return commands[0] if commands.length == 1
  i = partial_command.length-1
  while (i += 1) >= 0
    common_char = null
    for command in commands
      if (command.length == i)
        return command.slice(0,i)
      else
        if (!common_char)
          common_char = command[i]
        else if (command[i] != common_char)
          return command.slice(0,i)

commands =
  help : (args) -> term_out(Object.keys(commands).join(' '))
  ls : (args) ->
    $.getJSON('/paths',
      path: args[0]
      current_entity: $('#entity').attr('entity_id'),
      (data) ->
        if data["names"]
          if data["names"].length > 0
            term_out data["names"].join(' ')
          else
            term_out "Entity has no subentities."
        term_err data["error"] if data["error"])
  "~" : (args) ->
    alert 'TODO: Search in documents.'
  "-" : (args) ->
    alert 'TODO: Show first document.'
  "=" : (args) ->
    $.getJSON('/entities/autocomplete_name_value',
      path: args[0]
      (data) ->
        alert data
        )
  cd : (args) ->
    $.getJSON('/paths/get_entity',
      path: args[0]
      current_entity: $('#entity').attr('entity_id'),
      (data) ->
        if data["entity"]
          window.location.replace('/entities/' + data["entity"]["id"])
        term_err data["error"] if data["error"])
  login : (args) ->
    alert 'login'
  logout : (args) ->
    alert 'logout'
  mv : (args) ->
    alert 'mv'
  cp : (args) ->
    alert 'cp'
  clear : (args) ->
    $('#terminal_output').html('')

$.fn.terminal = (options) ->

  settings = $.extend(
    'font-color'              : 'light-green'
    'background-color'        : 'black',
    options)

  this.bind('keyup', (event) ->
    command_parts = term_in().split(' ')
    command = command_parts[0]
    if event.which == 13 # Execute on ENTER.
      return term_err('Command ' + command + ' does not exist.') unless commands[command]
      
      commands[command](command_parts.slice(1))
      term_in ''
    else if event.which == 9 # Autocomplete on TAB.
      if command_parts.length == 1
        possible_commands = new Array()
        for command_name, command_value of commands
          if command == command_name.slice(0,command.length)
            possible_commands.push(command_name)
        if possible_commands.length == 1
          term_in(possible_commands[0] + ' ')
        else if possible_commands.length > 1
          term_in(longest_common_chars(command, possible_commands))
          term_out(possible_commands.join(' '))
      else # Autocomplete path
        path = command_parts[command_parts.length-1]
        $.getJSON('/paths',
          path: if path.lastIndexOf('/') == -1 then '.' else path.substring(0, path.lastIndexOf('/')+1)
          partial_name: if path.lastIndexOf('/') == -1 then path else path.substring(path.lastIndexOf('/')+1)
          current_entity: $('#entity').attr('entity_id'),
          (data) ->
            if data["names"] && data["names"].length > 0
              if data["names"].length == 1
                term_in(command_parts[0..-2].join(' ') + ' ' + data["names"] + '/')
                term_out ''
              else
                term_in(command_parts[0..-2].join(' ') + ' ' + longest_common_chars(command_parts[command_parts.length-1], data["names"]))
                term_out data["names"].join(' ')
            term_err data["error"] if data["error"])
      event.preventDefault()
      return false
    else if event.which == 27 # Clear output on ESC.
      term_out('')
  ).bind('keydown', (event) ->
    if event.which == 9
      event.preventDefault()
      return false)

$(document).ready(-> $('.terminal').terminal())
