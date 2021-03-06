module DocumentsHelper

  def documents_for_entity(entity, page, per_page)
    definition_document = entity.documents.find_by_name("definition")
    documents = DeleteRequest.alive_scope(definition_document.documents.where(language_id: current_language.id),
      current_user).paginate(page: params[:document_page], per_page: per_page) if definition_document
  end

  def ancestors_documents(entity)
    documents = {}
    entity.ancestors.each do |e|
      e.listing_documents.each {|d| documents[d.name] ||= d }
    end
    documents.values
  end

end
