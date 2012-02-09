class Document < ActiveRecord::Base
 
  default_scope includes(:delete_request)
 
  has_and_belongs_to_many :entities
  
  #require "uri_validator"
  #validates :source, :presence => true, :uri => { :format => /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix }
  validates :source, :presence => true

  validates_presence_of :name
  validates_presence_of :content
  validates_presence_of :description
  validates_presence_of :language_id

  validates_uniqueness_of :name

  has_one :delete_request, :inverse_of => :destroyable, :dependent => :destroy, :as => :destroyable

  has_many :ratings, :inverse_of => :rankable, :as => :rankable, :dependent => :destroy

  has_many :possible_document_types, :inverse_of => :document

  belongs_to :language

  SOURCE_ENCYCLO = "http://www.encyclo.com"

  def local_document?
    self.source == SOURCE_ENCYCLO
  end
end
