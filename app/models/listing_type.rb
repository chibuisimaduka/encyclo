class ListingType
  
  attr_reader :id, :show_tags, :show_descriptions, :show_documents

  def initialize(id, values)
    @id = id
    values.each {|k,v| self.instance_variable_set "@#{k}", v }
  end

  LISTING_TYPES = {
    "expanded" => ListingType.new(:expanded,        {:show_tags => true,  :show_descriptions => true,  :show_documents => true }),
	 "entity_list" => ListingType.new(:entity_list,  {:show_tags => false, :show_descriptions => false, :show_documents => false}),
	 "doc_list" => ListingType.new(:doc_list,        {:show_tags => false, :show_descriptions => false, :show_documents => true}),
	 "doc_tag_list" => ListingType.new(:doc_tag_list,{:show_tags => true,  :show_descriptions => false, :show_documents => true})
  }
  EXPANDED = LISTING_TYPES["expanded"]
  ENTITY_LIST = LISTING_TYPES["entity_list"]
  DOCUMENT_LIST = LISTING_TYPES["doc_list"]
  TAG_AND_DOCUMENT_LIST = LISTING_TYPES["doc_tag_list"]

  def to_s
    @id
  end

end
