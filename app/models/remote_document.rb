class RemoteDocument < ActiveRecord::Base

  require 'downloader'
  extend Downloader

  has_one :document, :as => :documentable
  #validates_presence_of :document

  #require "uri_validator"
  #validates :source, :presence => true, :uri => { :format => /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix }
  validates :url, :presence => true

  def self.find_or_initialize_by_url(url) # Active record method not calling initialize...
    RemoteDocument.find_by_url(url) || RemoteDocument.initialize_by_url(url)
  end

  def self.initialize_by_url(url)
    remote_document = RemoteDocument.new
    fetched_url, fetched_content = download(url)
    remote_document.url = fetched_url
    remote_document.content = fetched_content
    remote_document
  end

end
