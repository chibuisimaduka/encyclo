# The Wolf fixes stuff.
namespace :wolf do

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

    task :update_documents => :environment do
      Entity.all.each {|e| e.update_documents_from_tag_sources }
    end

    desc "Do the initial ranking for entities."
    task :rank => :environment do
      rank(Entity.all)
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

end

def rank(list)
  list.each do |e|
    score = 0.0
    num = 0
    RankingElement.find_all_by_record_id(e.id).each do |r|
      score += r.rating
      num += 1
    end
    e.update_attribute(:rank, (score/num)) if num > 0
    e.update_attribute(:num_votes, num)
  end
end
