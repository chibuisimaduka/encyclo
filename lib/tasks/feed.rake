desc "Load entities from the given SRC_FILE"
task :load_entities => :environment do
  raise "Missing SRC_FILE" unless ENV['SRC_FILE']
  File.open(ENV['SRC_FILE'], "r") do |infile|
    while (line = infile.gets)
      if line.include?("/")
        entity_name, tag_name = line.split("/")
        tag = Tag.find_or_initialize_by_name(tag_name).strip
        unless tag.persisted?
          tag.create_entity!(name: tag.name)
          tag.save!
        end
        entity = Entity.new(name: entity_name, parent_tag: tag)
        entity.save
      end
    end
  end
end

desc "Create entities having the parent word based on words seperated by newlines."
task :load_words => :environment do
  raise "Missing SRC_FILE" unless ENV['SRC_FILE']
  lang = Language.find_by_name("english")
  entity_word = Name.find_by_value_and_language_id("word", lang.id).entity
  File.open(ENV['SRC_FILE'], "r") do |infile|
    while (word = infile.gets.strip)
      entity = Entity.new(parent_id: entity_word.id)
      entity.names.build(language_id: lang.id, value: word)
      entity.save
    end
  end
end

desc "Enter the years as entities."
task :load_years => :environment do
  lang = Language.find_by_name("english")
  entity_year = Entity.find 49203
  2100.times do |i|
    entity = Entity.new(parent_id: entity_year.id)
    entity.names.build(language_id: lang.id, value: i)
    entity.save
  end
end
