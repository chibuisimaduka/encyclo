task :init => :environment do
  WEBMASTER = User.find(9)
end

# The Wolf fixes stuff.
namespace :wolf do

task :destroy_components => :init do
  Component.all.each do |c|
    c.entities.destroy_all
    c.destroy
  end
end

task :recalculate_alives => :init do
  DeleteRequest.all.each do |d|
    new_value = d.considered_deleted?
    d.update_attribute :considered_destroyed, new_value unless d.considered_destroyed == new_value
  end
end

desc "Destroy any invalid record for the given model names comma separated."
task :clean => :init do
  raise "Missing CLASSES argument." unless ENV['CLASSES']
  (ENV['CLASSES'].split(',').map {|c| Kernel.const_get(c)}).each do |model|
    puts "There is #{model.count} #{model.name} before cleanup."
    model.transaction do
      model.all.each do |record|
        record.destroy unless record.valid?
      end
    end
    puts "There is #{model.count} #{model.name} after cleanup."
  end
end

namespace :predicates do
  
  task :remove_invalid_values => :init do
    Predicate.all.each do |p|
      vals = p.values
      vals.delete_if {|v| !Predicate.validate_one_value(p.component.component_type, v).blank? }
      p.value = vals.to_json
      p.save!
    end
  end

end

namespace :components do
  
  task :set_default_type => :init do
    default = ComponentType::ENTITY_REF
    Component.all.each do |c|
      c.update_attribute :component_type, default
    end
  end

end

namespace :documents do

  desc "Do the initial ranking for documents."
  task :rank => :init do
    rank(Document.all)
  end

  task :refetch => :init do
    Document.all.each {|d| d.fetch.process.save! }
  end

  task :reprocess_remote => :init do
    require 'remote_document_processor'
    Document.transaction do
      Document.all.each do |d|
        unless d.local_document?
          RemoteDocumentProcessor.new(d).process
          d.save
        end
      end
    end
  end

end

namespace :entities do

  task :ancestors => :init do
    all_entities_map = Hash[Entity.includes(:entities, :ancestors).all.map {|e| [e.id, e] }]
    Entity.where("parent_id IS NULL").each {|e| set_entity_ancestors(e, [], all_entities_map) }
  end

  def set_entity_ancestors(entity, child_ancestors, all_entities_map)
    entity.update_attribute :ancestors, child_ancestors unless entity.ancestors == child_ancestors
    (entity.entity_ids || []).each {|s| set_entity_ancestors(all_entities_map[s], (child_ancestors || []) + [entity], all_entities_map) }
  end

  task :migrate_names => :init do
    PossibleNameSpelling.includes([:name, :edit_request => :agreeing_users]).all.each do |n|
      if n.name.edit_request
        puts n.id
      else
        if n.edit_request.blank?
          begin
            EditRequest.update(n, n.name.possible_name_spellings, WEBMASTER)
            puts "Created edit request"
          rescue
            puts "Error while creating edit request p = #{n.id}"
            next
          end
        end
        begin
          n.name.edit_request = n.edit_request
          n.name.save
        rescue
          puts("Did not save name = #{n.name.id}, p = #{n.id}")
        end
      end
    end
  end

  task :create_possible_name_spellings => :init do
    user = User.find_by_email("webmaster")
    raise "Need a valid user" if user.blank?
    Entity.includes(:names => {:possible_name_spellings => {:edit_request => :agreeing_users}}).all.each do |e|
      e.names.each do |n|
        possible_name_spelling = n.possible_name_spellings.find_or_create_by_spelling(n.value)
        EditRequest.update(possible_name_spelling, possible_name_spelling.name.possible_name_spellings, user)
      end
    end
  end

  task :set_is_leaf => :init do
    Entity.all.each do |e|
      e.update_attribute :is_leaf, e.entities.blank?
    end
  end

  desc "Update documents from tag sources for every entity"
  task :update_documents => :init do
    (ENV['tag'] ? Tag.find_by_name(ENV['tag']).all_entities : Entity.all).each do |e| 
      puts "Updating #{e.name} documents."
      e.update_documents_from_tag_sources
    end
  end

  desc "Do the initial ranking for entities."
  task :rank => :init do
    Entity.all.each do |e|
      e.update_attribute :rank, e.ratings.blank? ? nil : e.ratings.collect(&:value).sum / e.ratings.size
    end
  end

  desc "Recreate images versions"
  task :images => :init do
    Entity.all.each do |e|
      unless e.images.blank?
        e.images.each do |i|
          i.image.recreate_versions!
        end
      end
    end
  end

  task :similarities => :init do
    Entity.all.each do |e|
      puts "Setting entity similarities for entity = #{e.name}"
      RankingElement.find_all_by_record_id(e.id).each do |elem|
        (elem.ranking.ranking_elements.all - [elem]).each do |other_elem|
          similarity = (1 - (0.25*(elem.rating - other_elem.rating)))
          if (similarity > 0)
            e.entity_similarities.create(:coefficient => similarity, :other_entity_id => other_elem.record_id)
          end
        end
      end
      e.save!
    end
  end

end

end
