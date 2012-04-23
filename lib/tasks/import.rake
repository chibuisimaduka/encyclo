namespace :import do

  namespace :wikipedia do

    task :documents => :init do
      raise "Missing INPUT_FILE" unless ENV['INPUT_FILE']

      file = File.open(ENV['INPUT_FILE'], 'r')
      while (line = file.gets) do
        freebase_id, url = line.chomp.split("\t")
        puts "Processing entity freebase_id=#{freebase_id}"
        entity = Entity.includes(:documents).find_by_freebase_id(freebase_id)
        if !entity
          puts "Missing entity."
        else
          if entity.documents.length > 0
            puts "Skipping. Already has documents."
          else
            min_delay 1 do
              listing = Document.init({name: "definition", documentable_type: "ListingDocument", entity_ids: entity.id},
                                       nil, nil, WEBMASTER, ENGLISH)
              begin
                if listing.save && RemoteDocument.create_document(nil, url, {parent_document_attributes: {parent_id: listing.id}}, WEBMASTER, ENGLISH)
                  puts "Successfully created one document!"
                else
                  puts "Error creating document for entity id=#{entity.id}"
                end
              rescue Exception => e
                puts "Exception caught: #{e.message}"
              end
            end
          end
        end
      end
    end

    task :images => :init do
      raise "Missing INPUT_FILE" unless ENV['INPUT_FILE']

      file = File.open(ENV['INPUT_FILE'], 'r')
      while (line = file.gets) do
        min_delay 1 do
          document_id, url = line.chomp.split("\t")
          puts "Processing document document_id=#{document_id}"
          document = RemoteDocument.find(document_id).document
          entity = document.parent ? document.parent.entities.first : document.entities.first
          if !entity
            puts "Missing entity."
          else
            if entity.images.count > 0
              puts "Skipping. Already has images."
            else
              begin
                image = entity.images.build(remote_image_url: url)
                image.user_id = WEBMASTER.id
                image.source = url
                if !entity.save
                  puts "An error has occured while creating the image."
                end
              rescue Exception => e
                puts "Exception caught: #{e.message}"
              end
            end
          end
        end
      end
    end
 
  end

  namespace :freebase do

    task :before_create => :init do
      raise "Missing PARENT_ID or TYPE." unless ENV["PARENT_ID"] && ENV["TYPE"]
      @type = ENV["TYPE"]
      @parent_id = ENV["PARENT_ID"].to_i
    end

    task :create_entities => :before_create do
      statement = "INSERT INTO entities (user_id,is_intermediate,parent_id,freebase_id) VALUES"
      FreebaseEntity.find_all_by_freebase_type(@type).each do |e|
        statement += "(#{WEBMASTER.id},false,#{@parent_id},#{}),"
      end
      Entity.connection.execute (statement.chomp + ";")
    end

    task :create_names => :before_create do
      statement = "INSERT INTO names (language_id,entity_id,value) VALUES"
      freebase_entities = Hash[FreebaseEntity.find_all_by_freebase_type(@type).map {|e| [e.freebase_id, e] }]
      Entity.where("freebase_id IS NOT NULL and parent_id=", @parent_id).each do |e|
        statement += "(#{ENGLISH.id},#{e},#{freebase_entities[e.freebase_id].name}),"
      end
      Name.connection.execute (statement.chomp + ";")
    end

    task :create_edit_requests => :before_create do
      statement = "INSERT INTO edit_requests (editable_type,editable_id) VALUES"
      Name.joins(:entity).where("entities.freebase_id IS NOT NULL and entities.parent_id=", @parent_id).each do |n|
        statement += "('Name',#{n.id}),"
      end
      EditRequest.connection.execute (statement.chomp + ";")
    end

    task :create_users_edit_requests => :before_create do
      statement = "INSERT INTO users_edit_requests (user_id,edit_request_id) VALUES"
      EditRequest.joins(:name => :entity).where("entities.freebase_id IS NOT NULL and entities.parent_id=", @parent_id).each do |e|
        statement += "(#{WEBMASTER.id},#{e.id}),"
      end
      EditRequest.connection.execute (statement.chomp + ";")
    end

    desc "Create Entities from FreebaseEntities"
    task :create => [:create_entities, :create_names, :create_edit_requests, :create_users_edit_requests]

  end
end

def min_delay(delay, &block)
  before = Time.now
  yield
  time_sleep = delay.to_f - (Time.now - before)
  sleep(time_sleep) if time_sleep > 0
end
