module Downloader
  
  require 'uri'
  require 'net/http'

  def old_download(raw_uri)
    uri = URI.parse(URI.escape(URI.unescape(raw_uri)))
    full_path = (uri.query.blank?) ? uri.path : "#{uri.path}?#{uri.query}"
    request = Net::HTTP::Get.new(URI.encode(full_path))
    res = Net::HTTP.start(uri.host, uri.port) {|http|
      http.request(request)
    }
    res.body
  end
  
  def download(requested_url)
    url = URI.parse(requested_url)
    full_path = (url.query.blank?) ? url.path : "#{url.path}?#{url.query}"
    the_request = Net::HTTP::Get.new(full_path)

    the_response = Net::HTTP.start(url.host, url.port) { |http|
      http.request(the_request)
    }

    return the_response.body       
end

end
