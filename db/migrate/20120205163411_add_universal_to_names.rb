class AddUniversalToNames < ActiveRecord::Migration
  def change
    add_column :names, :universal, :boolean
  end
end
