#!/usr/bin/ruby

require 'script_authentication'

# using grep -P because regular grep regex does not understand \t, but -P is only for GNU grep..
installed_packages = `sudo dpkg --get-selections | grep "install" | grep -P -o "^[^\t]*"`.split('\n')

for package in installed_packages
  entities << entity_application.entities.where(package_name: package)
end

# TODO: Find the entity id for every package, knowing that it is an application.
http_encyclo { |http|
  response = http.get('/entities/autocomplete', "names=#{installed_packages.to_json}")
}

entity_attributes = {
  name: gets,
  parent_name: gets,
  associations_values:
}

serialized_entity = entity_attributes.to_json

auth_token = authenticate

http_encyclo { |http|
  response = http.post('/entities/push', "auth_token=#{auth_token}&entity=#{serialized_entity}")
}
