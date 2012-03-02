class Document < ActiveRecord::Base

  MAX_DESCRIPTION_LENGTH = 250
 
  default_scope includes(:delete_request)

  attr_protected :user_id, :user

  belongs_to :documentable, :polymorphic => true
  validates_presence_of :documentable

  has_and_belongs_to_many :entities
 
  belongs_to :user, :inverse_of => :documents
  validates_presence_of :user

  belongs_to :language
  validates_presence_of :language

  has_one :delete_request, :inverse_of => :destroyable, :dependent => :destroy, :as => :destroyable

  has_many :ratings, :inverse_of => :rankable, :as => :rankable, :dependent => :destroy

  has_many :possible_document_types, :inverse_of => :document, :dependent => :destroy
  
  validates_presence_of :name
  validates_presence_of :description
  validates_length_of :description, :minimum => 25, :maximum => MAX_DESCRIPTION_LENGTH

end
