class AddTokenToGame < ActiveRecord::Migration
  def change
    add_column :games, :token, :string, :limit => 24
  end
end
