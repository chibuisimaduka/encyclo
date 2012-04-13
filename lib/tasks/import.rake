namespace :import do

  namespace :freebase do

    task :entities do
      type = ENV['TYPE'] # The types of entities to get.
      raise "Missing the type of entities you want to fetch!" if type.blank?
      File.open(ENV['INPUT_FILE'], "r") do |infile|
        while (entry = infile.gets)
          entry = entry.chomp
          if entry[entry.index("\t")..-1] == "/type/object/type\t#{type}"
            FreebaseEntity.create!(freebase_id: entry[0..entry.index("\t")], freebase_type: "#{type}")
          end
        end
      end
    end

    task :properties do
      puts "Loading all entities."
      all_entitites = Entity.where("freebase_id IS NOT NULL and parent_id = 862")
      puts "Mapping them to their freebase_id."
      entities = Hash[all_entities.map {|e| [e.freebase_id, e]}]
      puts "Starting reading file."
      File.open(ENV['INPUT_FILE'], "r") do |infile|
        while (entry = infile.gets)
          entry = entry.chomp
          entity = entities[entry[0..entry.index('\t')]]
          if entity
            entity
          end
        end
      end
      puts "All done!"
    end
  
  end

  task :freebase => :init do
    base_entity = Entity.find(1909)
    predicate1_id = predicate_id(base_entity, "movie")

    File.open(ENV['INPUT_FILE'], "r") do |infile|
      attributes_definition_str = infile.gets.chomp
      raise "Invalid input file. File is probably empty." if attributes_definition_str.blank?
      
      new_entries_count = 0 
      while (entry = infile.gets) && new_entries_count < 1
        attributes = entry.chomp.split("\t")
          begin
            Entity.transaction do
              entity = Entity.create({parent_id: base_entity.id, freebase_id: attributes[1]}, WEBMASTER, ENGLISH, attributes[0])
              raise "Invalid freebase_id!" if entity.freebase_id.blank? || entity.freebase_id == 0
              entity.names.first.save!
              create_association(predicate1_id, entity, attributes[2])
            end
          rescue
            puts "Error processing #{attributes[0]}, #{attributes[1]}. Msg = #{e.message}."
          end
        puts "100 entries entered!" if (new_entries_count += 1) % 100 == 0
      end
    end
  end

end

def predicate_id(base_entity, association_name)
  (base_entity.all_association_definitions(nil).keep_if do |d|
    Name.language_scope(d.associated_entity.names, Language::MAP[:english]).first.value == association_name
  end).first.id
end

def create_association(definition_id, entity, value)
  debugger
  association = Association.new(association_definition_id: definition_id,
                                entity_id: entity.id,
                                associated_entity_id: Entity.find_by_freebase_id(value).id)
  association.user_id = WEBMASTER.id
  association.save!
end
