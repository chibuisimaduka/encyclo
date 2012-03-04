class Document < ActiveRecord::Base

  MAX_DESCRIPTION_LENGTH = 250
 
  default_scope includes(:delete_request)

  attr_protected :user_id, :user

  belongs_to :documentable, :polymorphic => true, :dependent => :destroy, :autosave => true
  validates_presence_of :documentable

  has_and_belongs_to_many :entities
 
  belongs_to :user, :inverse_of => :documents
  validates_presence_of :user

  belongs_to :language
  validates_presence_of :language

  belongs_to :component

  has_one :delete_request, :inverse_of => :destroyable, :dependent => :destroy, :as => :destroyable

  has_many :ratings, :inverse_of => :rankable, :as => :rankable, :dependent => :destroy

  has_one :parent_document, :class_name => "ChildDocument", :foreign_key => "document_id", :inverse_of => :document
  has_one :parent, :through => :parent_document

  has_many :child_documents, :foreign_key => "parent_id", :inverse_of => :parent
  has_many :documents, :through => :child_documents, :order => "name"

  accepts_nested_attributes_for :parent_document
  
  validates_presence_of :name
  #validates_presence_of :description
  #validates_length_of :description, :minimum => 25, :maximum => MAX_DESCRIPTION_LENGTH

end
