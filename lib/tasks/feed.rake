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
