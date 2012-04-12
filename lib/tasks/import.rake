namespace :import do

  task :freebase => :init do
    base_entity = Entity.find(ENV['BASE_ENTITY_ID'])

    File.open(ENV['INPUT_FILE'], "r") do |infile|
      attributes_str = infile.gets.chomp
      raise "Invalid input file. File is probably empty." if attributes_str.blank?
      
      attributes_def = attributes_str.split("\t")
    
      #puts "Enter the field matching association, or leave blank to ignore." 
      #predicates = []
      #attributes_def[2..-1].each do |attr|
      #  puts "#{attr} : "
      #  association = gets.singularize
      #  if association.blank?
      #    predicates << nil
      #  else
      #    predicate = (base_entity.all_association_definitions.keep_if {|d| d.associated_entity.names.find_by_language_id(Language::MAP[:english]).value == association }).first
      #    raise "Invalid predicate name = #{association}" unless predicate
      #    predicates << predicate
      #  end
      #end 
     
      new_entries_count = 0 
      while (entry = infile.gets.chomp)
        attributes = entry.split("\t")
        begin
          Entity.transaction do
            entity = Entity.create({parent_id: base_entity.id, freebase_id: attributes[1]}, WEBMASTER, ENGLISH, attributes[0])
            entity.names.first.save! # Don't ask me why I do this..
            #attributes[2..-1].each_with_index do |attr, i|
            #  association = Association.new(association_definition_id: predicates[i].id, entity_id: entity.id)
            #  association.user_id = webmaster.id
            #  association.save!
            #end
          end
        rescue
          puts "Error processing #{attributes[0]}, #{attributes[1]}"
        end
        puts "100 entries entered!" if (new_entries_count += 1) % 100 == 0
      end
    end
  end

end
