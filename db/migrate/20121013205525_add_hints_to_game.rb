class AddHintsToGame < ActiveRecord::Migration
  def change
    add_column :games, :hints, :text
    add_column :games, :current_hint, :integer, default: 0
  end
end
