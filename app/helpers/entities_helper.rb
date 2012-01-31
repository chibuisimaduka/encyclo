module EntitiesHelper
  
  def associations_by_definition(entity)
    associations_by_def = {}
    entity.map_all(:parent, :all_association_definitions).each do |association_def|
      associations_by_def[association_def] = []
    end

    entity.associations.each do |association|
      associations_by_def[association.definition] += association
    end

    associations_by_def
  end

  def join(array, separator=" ", &block)
    str = ""
    array.each do |e|
      str += capture(e, &block).to_s
      str += separator
    end
    str = str[0..-(separator.size + 1)] unless array.blank?
    str.html_safe
  end

end
