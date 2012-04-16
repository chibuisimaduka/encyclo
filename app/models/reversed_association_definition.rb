class ReversedAssociationDefinition

  def self.model_name
    AssociationDefinition.model_name
  end

  def initialize(association)
    @association = association
  end

  def entity
    @association.associated_entity
  end

  def entity_id
    @association.associated_entity_id
  end

  def associated_entity
    @association.entity
  end

  def associated_entity_id
    @association.entity_id
  end

  def entity_has_many
    @association.associated_entity_has_many
  end

  def associated_entity_has_many
    @association.entity_has_many
  end

  def method_missing(method, *args)
    args.empty? ? @association.send(method) : @association.send(method, args)
  end

  def self.reverse(collection)
    collection.map {|e| ReversedAssociationDefinition.new(e) } if collection
  end

end
