class HomeController < ApplicationController

  def index
    # TODO: Use statistics to find most appropriate entities instead of static entities.
    # Using conditions so it does not raise an exception if one of the entity is missing.
    #@entities = Entity.all(:conditions => {:id => [862, 869, 1800, 863, 1303]})
    @entities = [Entity.find(862)]
  end

end
