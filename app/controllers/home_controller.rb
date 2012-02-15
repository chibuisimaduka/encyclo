class HomeController < ApplicationController

  def index
    @entities = Entity.safe_find([869, 862, 1154, 880, 864])
  end

end
