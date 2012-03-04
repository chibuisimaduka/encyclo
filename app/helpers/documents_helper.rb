module DocumentsHelper

  def documents_for_entity(entity, page, per_page)
    documents = DeleteRequest.alive_scope(entity.documents.where(language_id: current_language.id, component_id: nil),
      current_user).paginate(page: params[:document_page], per_page: per_page)
  end

end
