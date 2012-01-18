module Downloader
  
  require 'uri'
  require 'net/http'

  # FROM http://stackoverflow.com/questions/6934185/ruby-net-http-following-redirects
  def download(uri_str, limit = 10)
    raise ArgumentError, 'HTTP redirect too deep' if limit == 0

    url = URI.parse(uri_str)
    full_path = (url.query.blank?) ? url.path : "#{url.path}?#{url.query}"
    req = Net::HTTP::Get.new(full_path)
    response = Net::HTTP.start(url.host, url.port) { |http| http.request(req) }
    case response
      when Net::HTTPSuccess     then return uri_str, response.body
      when Net::HTTPRedirection then return download(response['location'], limit - 1)
      else
        response.error!
    end
  end

end
