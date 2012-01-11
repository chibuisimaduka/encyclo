namespace :rank do
  
  desc "Do the initial ranking for entities and documents."
  task :all => [:entities, :documents]

  desc "Do the initial ranking for entities."
  task :entities => :environment do
    rank(Entity.all)
  end
  
  desc "Do the initial ranking for documents."
  task :documents => :environment do
    rank(Document.all)
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
    end
  end

  task :entity_similarities => :environment do
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

