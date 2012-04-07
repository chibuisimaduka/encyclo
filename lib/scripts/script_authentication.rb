require "net/http"
require "json"

require "config/server"

# Asks the user for it's pseudo and password and
# returns the auth_token if the authentication succeded.
# Else, it retries 3 times or throws an exception.
def authenticate(options={})
  pseudo = gets

  num_attempts = 0
  while num_attempts++ < 4
    password = gets

    # FIXME: This is probably not encrypted.
    http_encyclo {|http|
      response = http.post('/sessions/create', "pseudo=#{pseudo}&password=#{pseudo}")
    }

    if response.code == "200"
      auth_token = JSON.parse(response.body)["auth_token"]
      raise "Good status code but blank auth_token." if auth_token.blank?
      return auth_token
    end

    puts "Failed authentication. Please try again: "
  end
  raise "Too many failed attempts."
end
