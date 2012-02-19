require 'spec_helper'

describe Entity do
  describe ".update" do
    it "should recalculate the ancestors when saved for itself and it's child" do
      entity = FactoryGirl.create(:entity)
      entity.entities.size.should_not == 0
      initial_parent = entity.parent
      entity.ancestors.should == [initial_parent]

      entity.parent = FactoryGirl.create(:childless_orphan_entity)
      entity.parent.should_not == initial_parent
      entity.ancestors.should == [entity.parent]
      entity.entities.each {|e| e.ancestors.should == [entity, entity.parent] }
    end
  end
end
