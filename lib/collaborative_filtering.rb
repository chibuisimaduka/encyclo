require 'linalg'

class EntitySimilarityMatrix
  
  private_class_method :new
           
  @@instance = EntitySimilarityMatrix.new
              
  def self.instance
    return @@instance
  end
                       
  def init(users, entities, ratings)
    @initalized = true
    @matrices = {}
    # Build a matrix for every category.
    entities.includes(:entities => :ratings).where("id IN (SELECT DISTINCT(parent_id) FROM entities)").each do |entity|
      # TODO: Reduce matrix size by loosing a little bit of accuracy.
      # FIXME: Use e.ancestors instead of e.entities, but that duplicated data..
      @matrices[entity.id] = e.entities.map {|e| users_ratings(users, e) }
    end
  end

  def add_entity(entity)
    @matrices[entity.parent_id] ?
  end

  def add_user(user)
  end

  def add_rating(user, entity, rating)
    @matrices[entity.id]
  end

  # Get the approximatives ranked entities for the given user.
  def get_best_entities(user)
  end
 
  # Get the estimated rating for the given user and entity.
  # Source : http://www.igvita.com/2007/01/15/svd-recommendation-system-in-ruby/
  def get_rating(user, entity)
    raise "Entity similarity matrix is not initialized!" unless @initialized

    m = @matrices[entity.id]
    # Compute the SVD Decomposition
    u, s, vt = m.singular_value_decomposition
    vt = vt.transpose
    
    # Take the 2-rank approximation of the Matrix
    #   - Take first and second columns of u  (6x2)
    #   - Take first and second columns of vt (4x2)
    #   - Take the first two eigen-values (2x2)
    u2 = Linalg::DMatrix.join_columns [u.column(0), u.column(1)]
    v2 = Linalg::DMatrix.join_columns [vt.column(0), vt.column(1)]
    eig2 = Linalg::DMatrix.columns [s.column(0).to_a.flatten[0,2], s.column(1).to_a.flatten[0,2]]
    
    # Here comes Bob, our new user
    bob = Linalg::DMatrix[[5,5,0,0,0,5]]
    bobEmbed = bob * u2 * eig2.inverse
    
    # Compute the cosine similarity between Bob and every other User in our 2-D space
    user_sim, count = {}, 1
    v2.rows.each { |x|
        user_sim[count] = (bobEmbed.transpose.dot(x.transpose)) / (x.norm * bobEmbed.norm)
            count += 1
              }
    
    # Remove all users who fall below the 0.90 cosine similarity cutoff and sort by similarity
    similar_users = user_sim.delete_if {|k,sim| sim < 0.9 }.sort {|a,b| b[1] <=> a[1] }
    
    # We'll use a simple strategy in this case:
    #   1) Select the most similar user
    #   2) Compare all items rated by this user against your own and select items that you have not yet rated
    #   3) Return the ratings for items I have not yet seen, but the most similar user has rated
    similarUsersItems = m.column(similar_users[0][0]-1).transpose.to_a.flatten
    myItems = bob.transpose.to_a.flatten
    
    not_seen_yet = {}
    myItems.each_index { |i|
      not_seen_yet[i+1] = similarUsersItems[i] if myItems[i] == 0 and similarUsersItems[i] != 0
    }
  end

private
  def users_ratings(users, entity)
    users.map do |u|
      rating = u.ratings.find_by_entity_id(entity.id)
      rating ? rating.value : 0
    end
  end
                                
end
