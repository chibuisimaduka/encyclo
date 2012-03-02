class RemoteDocument < ActiveRecord::Base

  include Downloader

  has_one :document, :as => :documentable
  validates_presence_of :document

  #require "uri_validator"
  #validates :source, :presence => true, :uri => { :format => /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix }
  validates :source, :presence => true

  def intialize(url)
    fetched_url, fetched_content = download(url)
    self.url = fetched_url
    self.content = fetched_content
  end

end
