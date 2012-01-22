# The Wolf fixes stuff.
namespace :wolf do

  desc "Backup the sorted_development database to the backups folder."
  task :backup do
    `mysqldump -u root sorted_development > backups/sorted_development_backup_#{Time.now.to_i}.sql`
  end

  namespace :documents do

    desc "Do the initial ranking for documents."
    task :rank => :environment do
      rank(Document.all)
    end

    task :refetch => :environment do
      Document.all.each {|d| d.fetch.process.save! }
    end

    task :reprocess => :environment do
      Document.all.each {|d| d.process.save! }
    end

  end

  namespace :entities do

    desc "Fixed the matching tag and the parent tag of every entity."
    task :fix_tags => :environment do
      Entity.all.each do |e|
        tag = Tag.find_by_name(e.name)
        unless tag.blank?
          # FIXME: Bad code, but I don't want to get into this.. Fucking associations..
          tag.entity = e
          tag.save!
          e.tag = tag
          e.parent_tag = tag.tag
          e.save!
        end
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
