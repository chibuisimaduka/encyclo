class Document < ActiveRecord::Base

  MAX_DESCRIPTION_LENGTH = 250
 
  default_scope includes(:delete_request)

  attr_protected :user_id, :user
 
  belongs_to :user, :inverse_of => :documents
  validates_presence_of :user

  belongs_to :language
  validates_presence_of :language

  has_and_belongs_to_many :entities

  has_one :delete_request, :inverse_of => :destroyable, :dependent => :destroy, :as => :destroyable

  has_many :ratings, :inverse_of => :rankable, :as => :rankable, :dependent => :destroy

  has_many :possible_document_types, :inverse_of => :document, :dependent => :destroy
  
  #require "uri_validator"
  #validates :source, :presence => true, :uri => { :format => /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix }
  validates :source, :presence => true

  validates_presence_of :name
  validates_presence_of :content
  validates_presence_of :description
  validates_length_of :description, :minimum => 25, :maximum => MAX_DESCRIPTION_LENGTH

  SOURCE_ENCYCLO = "http://www.encyclo.com"

  def link
    local_document? ? self : self.source
  end

  def local_document?
    self.source == SOURCE_ENCYCLO
  end

end
