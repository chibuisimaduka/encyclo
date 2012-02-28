class PrettyPrinter

  # PrettyPrint TODO:
  # - Entity parent don't show picture.

  attr_reader :num_documents

  def initialize(entity, entities)
    @num_documents = entities.blank? ? 3 : 1 
  end

end
