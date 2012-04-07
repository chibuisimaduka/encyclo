#!/usr/bin/ruby

require '../script_authentication'

auth_token = authenticate

entity_attributes = {
  name: gets,
  parent_name: gets,
  associations_values: 
}

serialized_entity = entity_attributes.to_json

Net::HTTP.start(EncycloServer::HOST, EncycloServer::PORT) {|http|
  response = http.post('/entities/push', "auth_token=#{auth_token}&entity=#{serialized_entity}")
}
