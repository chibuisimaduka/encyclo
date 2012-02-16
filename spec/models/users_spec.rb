require 'spec_helper'

describe User do
  describe ".destroy" do
    it "should destroy everything it has created" do
      user = Factory.create(:user)
      user.should not_be_nil
    end
  end
end
