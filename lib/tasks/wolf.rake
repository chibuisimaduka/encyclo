# The Wolf fixes stuff.
namespace :wolf do

  desc "Save the mysql dump to the backups directory. Load using mysql env < file."
  task :backup do
    filename = "backups/sorted_development_backup_#{(ENV["MSG"] || "").gsub(" ", "_")}_#{Time.now.to_i}.sql"
    `mysqldump -u root sorted_development > #{filename}`
    puts "Succesfully saved to #{filename}"
  end

  desc "Destroy any invalid record. You must update the list of models though."
  task :clean => :environment do
    [EditRequest].each do |model|
      model.transaction do
        model.all.each do |record|
          record.destroy unless record.valid?
        end
      end
    end
  end

  namespace :predicates do
    
    task :remove_invalid_values => :environment do
      Predicate.all.each do |p|
        vals = p.values
        vals.delete_if {|v| !Predicate.validate_one_value(p.component.component_type, v).blank? }
        p.value = vals.to_json
        p.save!
      end
    end

  end

  namespace :components do
    
    task :set_default_type => :environment do
      default = ComponentType::ENTITY_REF
      Component.all.each do |c|
        c.update_attribute :component_type, default
      end
    end

  end

  namespace :documents do

    desc "Do the initial ranking for documents."
    task :rank => :environment do
      rank(Document.all)
    end

    task :refetch => :environment do
      Document.all.each {|d| d.fetch.process.save! }
    end

    task :reprocess_remote => :environment do
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

    task :ancestors => :environment do
      all_entities_map = Hash[Entity.includes(:entities, :ancestors).all.map {|e| [e.id, e] }]
      Entity.where("parent_id IS NULL").each {|e| set_entity_ancestors(e, [], all_entities_map) }
    end

    def set_entity_ancestors(entity, child_ancestors, all_entities_map)
      entity.update_attribute :ancestors, child_ancestors unless entity.ancestors == child_ancestors
      (entity.entity_ids || []).each {|s| set_entity_ancestors(all_entities_map[s], (child_ancestors || []) + [entity], all_entities_map) }
    end

    task :calculate_names_value => :environment do
      Name.transaction do
        Name.includes(:possible_name_spellings => {:edit_request => :agreeing_users}).all.each do |n|
          n.recalculate_value
        end
      end
    end

    task :create_possible_name_spellings => :environment do
      user = User.find_by_email("webmaster")
      raise "Need a valid user" if user.blank?
      Entity.includes(:names => {:possible_name_spellings => {:edit_request => :agreeing_users}}).all.each do |e|
        e.names.each do |n|
          possible_name_spelling = n.possible_name_spellings.find_or_create_by_spelling(n.value)
          EditRequest.update(possible_name_spelling, possible_name_spelling.name.possible_name_spellings, user)
        end
      end
    end

    task :set_is_leaf => :environment do
      Entity.all.each do |e|
        e.update_attribute :is_leaf, e.entities.blank?
      end
    end

    desc "Update documents from tag sources for every entity"
    task :update_documents => :environment do
      (ENV['tag'] ? Tag.find_by_name(ENV['tag']).all_entities : Entity.all).each do |e| 
        puts "Updating #{e.name} documents."
        e.update_documents_from_tag_sources
      end
    end

    desc "Do the initial ranking for entities."
    task :rank => :environment do
      Entity.all.each do |e|
        e.update_attribute :rank, e.ratings.blank? ? nil : e.ratings.collect(&:value).sum / e.ratings.size
      end
    end

    desc "Recreate images versions"
    task :images => :environment do
      Entity.all.each do |e|
        unless e.images.blank?
          e.images.each do |i|
            i.image.recreate_versions!
          end
        end
      end
    end
  
    task :similarities => :environment do
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

  namespace :tags do

    desc "Merge tags with same name."
    task :merge_tags_with_same_name do
      Tag.all.each do |t|
        tags = Tag.find_all_by_name(t.name) - [t]
        unless tags.blank?
          tags.each { |dup| t.merge_with(dup) }
        end
      end
    end
    
    desc "Generate an entity for every tag that does not have a matching entity."
    task :generate_entities => :environment do
      Tag.all.each do |t|
        if t.entity.blank?
          t.create_entity!(name: t.name, parent_tag: t.tag)
        end
      end
    end

  end

end
