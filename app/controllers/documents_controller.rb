class DocumentsController < ApplicationController

  def index
    @entity = Entity.find(params[:entity_id])
  end

  def show
    @document = Document.find(params[:id])
    if @document.documentable_type == 'RemoteDocument'
      redirect_to @document.documentable.url
    end
  end

  def upload
    @entity = Entity.find(params[:entity_id])
    @document = Document.new
    # TODO: Add as image if it is an image.
    extension = File.extname(params[:file].original_filename)
    content = params[:file].read
    if (content =~ /[^[:print:]\n\t\v\r\a\e\f]/) != nil # "~=" returns the index. If 0, if would evaluate to true wrongly.
      redirect_to :back, :alert => <<-EOM
        The file was considered a text file based on the extension,
        but contains non-printable characters.
        EOM
    else
      @document.documentable = UserDocument.new(content: content)
      @document.name = params[:file].original_filename
      @document.language_id = current_language.id
      @document.user_id = current_user.id
      @document.description = content[0..(Document::MAX_DESCRIPTION_LENGTH-1)]
      if @entity.documents << @document
        redirect_to @document
      else
        redirect_to :back, :alert => "An error has occured while creating the document."
      end
    end
  end

end
