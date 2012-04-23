#!/usr/bin/ruby

$:.push('../gen-rb')

require 'thrift'
require 'entity_adviser'

begin
  port = 9090

  transport = Thrift::BufferedTransport.new(Thrift::Socket.new('localhost', port))
  protocol = Thrift::BinaryProtocol.new(transport)
  client = EntityAdviser::Client.new(protocol)

  transport.open()

  result = client.ping()
  if result
    puts "Pong"
  else
    puts "It does not work.."
  end
  
  transport.close()
rescue
  puts $!
end
