require 'spec_helper'

describe User do
  describe ".register" do
    it "should authenticate with matching username and password" do
      user = Factory.create(:user, :email => 'frank@encyclo.com', :password => 'secret')
      User.authenticate('frank@encyclo.com', 'secret').should == user
    end
                
    it "should not authenticate with incorrect password" do
      user = Factory.create(:user, :email => 'frank@encyclo.com', :password => 'secret')
      User.authenticate('frank', 'incorrect').should be_nil
    end
  end

  describe ".destroy" do
    it "should destroy the edit requests he has" do
      user = Factory.create(:user, :edit_requests => Factory.create_list(:possible_spelling_edit_request, 2))
      user.edit_requests.count.should == 2
    end
  end
end
