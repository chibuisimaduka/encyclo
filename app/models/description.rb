class Description < ActiveRecord::Base
  belongs_to :document

  def to_s
    content
  end
end
