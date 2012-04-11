namespace :import do

  task :freebase do
    puts "The base entity id : "
    base_entity = Entity.find(gets)

    File.open(ENV['INPUT_FILE'], "r") do |infile|
      attributes_str = infile.gets.chomp
      raise "Invalid input file. File is probably empty." if attributes_str.blank?
      
      attributes_def = attributes_str.split("\t")
    
      puts "Enter the field matching association, or leave blank to ignore." 
      predicates = []
      attributes_def[2..-1].each do |attr|
        puts "#{attr} : "
        association = gets.singularize
        if association.blank?
          predicates << nil
        else
          predicate = (base_entity.predicates.keep_if {|p| p.names.find_by_language_id(Language::MAP[:english]).value == association }).first
          raise "Invalid predicate name = #{association}" unless predicate
          predicates << predicate
        end
      end 
     
      webmaster = User.find(9)
      while (entry = infile.gets.chomp)
        attributes = entry.split("\t")
        entity = Entity.create({parent_id: base_entity.id, freebase_id: attributes[1]}, webmaster, Language::MAP[:english], attributes[0])
        attributes[2..-1].each_with_index do |attr, i|
          association = Association.new(association_definition_id: predicates[i])
          association.user_id = webmaster.id
          association.save!
        end
      end
    end
  end

end
