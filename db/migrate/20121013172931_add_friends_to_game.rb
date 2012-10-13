class AddFriendsToGame < ActiveRecord::Migration
  def up
    add_column :games, :guesses, :text

    remove_column :games, :target_id
    add_column :games, :target, :text
  end

  def down
    remove_column :games, :target
    add_column :games, :target_id, :integer

    remove_column :games, :guesses
  end
end
