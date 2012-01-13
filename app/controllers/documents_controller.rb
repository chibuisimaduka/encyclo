class DocumentsController < ApplicationController

  require 'open-uri'

  def show
    @document = Document.find(params[:id])
	 #@document.content = fetch @document.source
	 #@document.save!
  end

  def create
    @entity = Entity.find(params[:entity_id])
	 @document = @entity.documents.create(params[:document])
    uri = URI.parse(URI.escape(URI.unescape(@document.source)))
    @document.name = "#{uri.host} - #{@entity.name}"
	 @document.content = fetch(uri)
	 @document.save!
	 redirect_to @entity
  end

private
  def fetch(uri)
    res = Net::HTTP.start(uri.host, uri.port) {|http|
      http.get('/index.html')
    }
    res.body
  end

end
