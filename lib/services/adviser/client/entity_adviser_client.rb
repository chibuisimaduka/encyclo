class EntityAdviserClient

  require 'thrift'
  require 'entity_adviser'

  def self.get_suggestions(category_id, limit, offset, predicates)
    query_adviser do |client|
      result = client.get_suggestions(category_id, limit, offset, predicates)
    end
  end

  def self.update_entity_rank(entity_id, rank, category_id)
    query_adviser do |client|
      result = client.update_entity_rank(entity_id, rank, category_id)
    end
  end

  def self.query_adviser(&block)
    transport = Thrift::BufferedTransport.new(Thrift::Socket.new('localhost', 9090))
    protocol = Thrift::BinaryProtocol.new(transport)
    client = EntityAdviser::Client.new(protocol)
  
    transport.open()
    result = yield(client) 
    transport.close()

    result
  end

end
