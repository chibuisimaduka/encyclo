class Document < ActiveRecord::Base
  has_and_belongs_to_many :entities
  
  require "uri_validator"
  validates :source, :presence => true, :uri => { :format => /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix }

  validates_presence_of :name
  validates_presence_of :content
  validates_presence_of :description

  require "downloader"
  include Downloader

  require 'uri'
  require 'nokogiri'

  def fetch
	 self.content = download(self.source)
    self
  end

  def process
    @doc = Nokogiri::HTML(self.content)
    self.name = "#{source_host} - #{title_from_meta_tag || title_from_title_tag}"
    self.description = description_from_meta_tag || description_from_first_paragraph
    self
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

  def source_host
    URI.parse(URI.escape(URI.unescape(self.source))).host
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
