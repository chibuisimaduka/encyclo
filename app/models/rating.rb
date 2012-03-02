class Rating < ActiveRecord::Base

  attr_protected :user_id, :user

  belongs_to :user, :inverse_of => :ratings
  validates_presence_of :user

  belongs_to :rankable, :polymorphic => true
  validates_presence_of :rankable

  validates_presence_of :value

  validates_numericality_of :value, :greater_than => 0.0, :less_than_or_equal_to => 10.0

end
