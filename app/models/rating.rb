class Rating < ActiveRecord::Base

  attr_protected :user_id, :user

  belongs_to :user, :inverse_of => :ratings
  validates_presence_of :user

  belongs_to :rankable, :polymorphic => true
  validates_presence_of :rankable

  validates_presence_of :value

  validates_numericality_of :value, :greater_than => 0.0, :less_than_or_equal_to => 10.0

  def self.for(rankable, current_user)
    rankable.ratings.find_by_user_id(current_user.id)
  end

  # FIXME: WHY OH WHY DO I NEED THIS TO FIX THE RATING FORM!!!!!
  # Why the fuck does it calls to_s????
  def to_s
    "rating"
  end

end
