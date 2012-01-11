class DocumentsController < ApplicationController

  def show
    @document = Document.find(params[:id])
	 #@document.content = fetch @document.source
	 #@document.save!
  end

  def create
    @entity = Entity.find(params[:entity_id])
	 @document = @entity.documents.create!(params[:document])
	 #@document.content = fetch @document.source
	 #@document.save!
	 redirect_to @entity
  end

private
  def fetch(raw_url)
    require 'net/http'
    require 'uri'
    url = URI.parse(raw_url)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.get('/index.html')
    }
    res.body
  end

end
