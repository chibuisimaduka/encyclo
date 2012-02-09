class PrettyPrinter

  # PrettyPrint TODO:
  # - Entity parent don't show picture.

  attr_reader :num_documents

  def initialize(entity)
    @num_documents = entity.entities.blank? ? 3 : 1 
  end

end
