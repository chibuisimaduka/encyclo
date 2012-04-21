class RemoteDocument < ActiveRecord::Base

  require 'downloader'
  extend Downloader

  require 'remote_document_processor'
  extend RemoteDocumentProcessor

  has_one :document, :as => :documentable, :dependent => :destroy
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

  def self.create_document(entity, url, attributes, user, language)
    remote_document = RemoteDocument.find_or_initialize_by_url(url)
    unless remote_document.url == url
      remote_document = RemoteDocument.find_by_url(remote_document.url) || remote_document
    end
    if remote_document.persisted?
      if entity
        return entity.documents << remote_document.document unless entity.documents.include?(remote_document.document)
      else
        return remote_document.document.update_attributes(attributes)
      end
    else 
      document = process_remote_document(remote_document, attributes || {})
      document.user_id = user.id
      document.language_id = language.id
      return entity ? entity.documents << document : document.save
    end
  end

end
