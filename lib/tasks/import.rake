namespace :import do

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
