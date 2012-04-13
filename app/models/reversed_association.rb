class ReversedAssociation

  def initialize(association)
    @association = association
  end

  def entity
    @association.associated_entity
  end

  def associated_entity
    @association.entity
  end

  def method_missing(method, *args)
    args.empty? ? @association.send(method) : @association.send(method, args)
  end

  def self.reverse(collection)
    collection.map {|e| ReversedAssociation.new(e) } unless collection.blank?
  end

end
