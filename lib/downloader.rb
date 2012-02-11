module Downloader
  
  require 'uri'
  require 'net/http'

  # FROM http://stackoverflow.com/questions/6934185/ruby-net-http-following-redirects
  # FIXME: Check robots.txt before downloading webpage
  def download(uri_str, limit = 10)
    raise ArgumentError, 'HTTP redirect too deep' if limit == 0

    url = URI.parse(URI.escape(URI.unescape(uri_str)))
    full_path = (url.query.blank?) ? url.path : "#{url.path}?#{url.query}"
    req = Net::HTTP::Get.new(full_path)
    response = Net::HTTP.start(url.host, url.port) { |http| http.request(req) }
    case response
      when Net::HTTPSuccess     then return URI.escape(URI.unescape(uri_str)), response.body
      when Net::HTTPRedirection then return download(response['location'], limit - 1)
      else
        response.error!
    end
  end

  def download_images(html)
    scrape_urls(html) { |url|
      if IMAGE_FILE_EXTENSIONS.include?(extract_extension(url))
        save_file(to_absolute_uri(original_uri, url))
      end
    }
  end

private
  URL_ATTRIBUTES = ['href', 'src']
  IMAGE_FILE_EXTENSIONS = ['jpg', 'jpeg', 'gif', 'png', 'tiff']  

  require 'hpricot'
  require 'open-uri'

  # Originaly FROM http://crunchlife.com/articles/2009/01/07/another-ruby-image-scraper
  def scrape_urls(html)      
    Hpricot.buffer_size = 262144
    URL_ATTRIBUTES.each { |attribute|
      Hpricot(html).search("[@#{attribute}]").map { |tag|
        yield tag[attribute]
      }
    }
  end

  def to_absolute_uri(original_uri, url)
    url = URI.parse(url)     
    url = original_uri + url if url.relative?  
    url.normalize        
  end

  def extract_extension(url)
    index = url.rindex('.')
    url[index..-1] if index
  end

end
