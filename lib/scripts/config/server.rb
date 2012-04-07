class EncycloServer
  HOST = "localhost"
  PORT = 3000
end

def http_encyclo(&block)
  Net::HTTP.start(EncycloServer::HOST, EncycloServer::PORT, &block)
end
