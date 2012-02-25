class HomeController < ApplicationController

  def index
    # TODO: Use statistics to find most appropriate entities instead of static entities.
    # Using conditions so it does not raise an exception if one of the entity is missing.
    @entities = Entity.all(:conditions => {:id => [724, 869, 862, 1154, 880, 864]})
  end

end
