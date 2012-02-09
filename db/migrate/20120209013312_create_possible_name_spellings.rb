class CreatePossibleNameSpellings < ActiveRecord::Migration
  def change
    create_table :possible_name_spellings do |t|
      t.string :spelling
      t.integer :name_id

      t.timestamps
    end
  end
end
