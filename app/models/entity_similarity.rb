class EntitySimilarity < ActiveRecord::Base
  belongs_to :entity
  belongs_to :other_entity
end
