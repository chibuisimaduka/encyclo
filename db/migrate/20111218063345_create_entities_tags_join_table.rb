class CreateEntitiesTagsJoinTable < ActiveRecord::Migration
  def self.up
    create_table :entities_tags, :id => false do |t|
	   t.integer :entity_id
	   t.integer :tag_id
    end
  end

  def self.down
    drop_table :entities_tags
  end
end
