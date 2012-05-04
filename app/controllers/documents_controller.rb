class DocumentsController < ApplicationController

  respond_to :html, :json, :js

  def index
    @entity = Entity.find(params[:entity_id])
    respond_to do |format|
      format.html {redirect_to :back}
      format.js
    end
  end

  def show
    @document = Document.find(params[:id])
    if @document.documentable_type == 'RemoteDocument'
      redirect_to @document.documentable.url
    end
  end

  def edit
    @document = Document.find(params[:id])
  end

  def update
    @document = Document.find(params[:id])
    @document.update_attributes(params[:document])
    if @document.documentable_type == 'RemoteDocument'
      render "edit"
    end
    respond_with @document
  end

  def create
    @document = Document.init(params[:document], nil, nil, current_user, current_language)
    if @document.save
      respond_with @document
    else
      redirect_to :back, :alert => "An error has occured while creating the document."
    end
  end
    
  def upload
    @entity = Entity.find(params[:entity_id]) if params[:entity_id]
    # TODO: Add as image if it is an image.
    extension = File.extname(params[:file].original_filename)
    content = params[:file].read
    if (content =~ /[^[:print:]\n\t\v\r\a\e\f]/) != nil # "~=" returns the index. If 0, if would evaluate to true wrongly.
      redirect_to :back, :alert => <<-EOM
        The file was considered a text file based on the extension,
        but contains non-printable characters.
        EOM
    else
      @document = Document.init(params[:document], params[:file].original_filename,
        UserDocument.new(content: content), current_user, current_language)
      @document.description = content[0..(Document::MAX_DESCRIPTION_LENGTH-1)] if @entity
      if @entity ? @entity.documents << @document : @document.save
        redirect_to @document
      else
        redirect_to :back, :alert => "An error has occured while creating the document."
      end
    end
  end

end
