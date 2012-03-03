module DocumentsHelper

  def documents_for_entity(entity, is_about, page, per_page)
    filters = {language_id: current_language.id, is_about: is_about}
    filters[:document_type_id] = document_type_filter.id unless document_type_filter.blank? 
    documents = DeleteRequest.alive_scope(entity.documents.where(filters), current_user)
    documents.paginate(page: params[:document_page], per_page: per_page)
  end

end
