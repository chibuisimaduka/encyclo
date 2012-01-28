class Predicate < ActiveRecord::Base
  belongs_to :component, :inverse_of => :predicates
  belongs_to :entity

  validates_presence_of :component_id
  validates_presence_of :entity_id

  has_many :entity_refs, :inverse_of => :predicate

  def method_missing(method_name, *args)
    super unless method_name[0..5] == "value_"
    val = values[method_name[6..-1].to_i]
    self.component.component_type == ComponentType::ENTITY_REF ? EntityRef.new(val).name : val
  end

end
