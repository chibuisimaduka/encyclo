#!/usr/bin/ruby

$:.push('../gen-rb')

require 'thrift'
require 'entity_adviser'

begin
  transport = Thrift::BufferedTransport.new(Thrift::Socket.new('localhost', 9090))
  protocol = Thrift::BinaryProtocol.new(transport)
  client = EntityAdviser::Client.new(protocol)

  transport.open()

  puts "Starting query"
  result = client.get_suggestions(862, 20, 0, [])
  puts result.inspect
  puts "Query done"
  
  transport.close()
rescue
  puts "Exception occured: " + $!.message
end
