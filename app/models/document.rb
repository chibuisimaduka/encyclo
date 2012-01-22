class Document < ActiveRecord::Base
  has_and_belongs_to_many :entities
  
  require "uri_validator"
  #validates :source, :presence => true, :uri => { :format => /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix }
  validates :source, :presence => true

  validates_presence_of :name
  validates_presence_of :content
  validates_presence_of :description

  require "downloader"
  include Downloader

  require 'uri'
  require 'nokogiri'

  def fetch
	 url, self.content = download(self.source)
    self.source = url
    self
  end

  def process
    @doc = Nokogiri::HTML(self.content)
    self.name = title_from_meta_tag || title_from_title_tag
    self.description = description_from_meta_tag || description_from_first_paragraph || "WTF"
    self
  end

  def self.create(entity, source)
    uri = URI.parse(URI.escape(URI.unescape(source.url)))
    if (entity.documents.keep_if {|d| d.source_host == uri.host }).blank?
      document = Document.new(source: source.url + URI.escape(URI.unescape(entity.name)))
      document.entities << entity
      entity.documents << document
      document.fetch
      content = document.content.downcase
      unless content.include?("no results found") or content.include?("did you mean")
        return document.process.save
      end
    end
    false
  end

  def source_host
    URI.parse(URI.escape(URI.unescape(self.source))).host
  end

private
  def title_from_title_tag
    title = @doc.css("title")
    title.first.content unless title.blank?
  end

  def title_from_meta_tag
    title = @doc.css("meta[name=title]")
    title.first["content"] unless title.blank?
  end

  def description_from_meta_tag
    desc = @doc.css("meta[name=description]")
    desc.first["content"] unless desc.blank?
  end

  def description_from_first_paragraph
    @doc.xpath("//p").each do |e|
      return e.content if e.content.size > 150
    end
    nil
  end

end
