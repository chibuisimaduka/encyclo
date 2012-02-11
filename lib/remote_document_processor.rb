class RemoteDocumentProcessor
  
  require "downloader"
  include Downloader

  require 'uri'
  require 'nokogiri'

  ENGLISH_LANGUAGES_MAP = Hash.new {|hash, key| Language::MAP[key]}
  ENGLISH_LANGUAGES_MAP.merge({
    :english => Language::MAP[:english],
    :french => Language::MAP[:francais],
    :spanish => Language::MAP[:spanish]
  })

  def initialize(document)
    raise "Can only process remote document" if document.local_document?
    @document = document
  end
  
  def fetch
	 url, @document.content = download(@document.source)
    @document.source = url
    self
  end

  def process
    @doc = Nokogiri::HTML(@document.content)
    @document.name = title_from_meta_tag || title_from_title_tag
    @document.description = description_from_meta_tag || description_from_first_paragraph || "No description.."
    #@document.language_id = ENGLISH_LANGUAGES_MAP[@document.description.language.to_sym].id
    self
  end

  def self.create(entity, source)
    raise "FIXME"
    uri = URI.parse(URI.escape(URI.unescape(source.url)))
    if (entity.documents.keep_if {|d| d.source_host == uri.host }).blank?
      document = Document.new(source: source.url + URI.escape(URI.unescape(entity.names.find_by_language_id(Language.find_by_name("english")))))
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
    URI.parse(URI.escape(URI.unescape(@document.source))).host
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
