class Rating < ActiveRecord::Base
  belongs_to :user
  belongs_to :rankable, :polymorphic => true

  validates_presence_of :value
  validates_presence_of :user
  validates_presence_of :rankable

  #validates_numericality_of :value, :greater_than => 0.0
  #validates_numericality_of :value, :less_than_or_equal_to => 10.0

end
