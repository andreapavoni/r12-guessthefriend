class CreateClues < ActiveRecord::Migration
  def change
    create_table :clues do |t|
      t.string :key
      t.string :question_it
      t.string :question_en
      t.integer :credits
      t.integer :used
      t.integer :guessed
      t.text :comment

      t.timestamps
    end
  end
end
