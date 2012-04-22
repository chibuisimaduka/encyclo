class Document < ActiveRecord::Base

  MAX_DESCRIPTION_LENGTH = 250
 
  default_scope includes(:delete_request)

  attr_protected :user_id, :user

  belongs_to :documentable, :polymorphic => true, :dependent => :destroy, :autosave => true
  validates_presence_of :documentable_type

  has_and_belongs_to_many :entities
 
  belongs_to :user, :inverse_of => :documents
  validates_presence_of :user

  belongs_to :language
  validates_presence_of :language

  has_one :delete_request, :inverse_of => :destroyable, :dependent => :destroy, :as => :destroyable

  has_many :ratings, :inverse_of => :rankable, :as => :rankable, :dependent => :destroy

  has_one :parent_document, :class_name => "ChildDocument", :foreign_key => "document_id", :inverse_of => :document, :dependent => :destroy
  has_one :parent, :through => :parent_document

  has_many :child_documents, :foreign_key => "parent_id", :inverse_of => :parent, :dependent => :destroy
  has_many :documents, :through => :child_documents, :order => "name", :dependent => :destroy

  accepts_nested_attributes_for :parent_document
  accepts_nested_attributes_for :documentable
  
  validates_presence_of :name
  #validates_presence_of :description
  #validates_length_of :description, :minimum => 25, :maximum => MAX_DESCRIPTION_LENGTH

  def self.init(attributes, name, documentable, user, language)
    document = Document.new(attributes || {})
    document.name = name if name
    document.documentable = documentable if documentable
    document.user = user
    document.language = language
    document
  end

  def death_treshold
    Math.log((self.documents.sum(&:death_treshold) + self.ratings.count) * 2)
  end

end
