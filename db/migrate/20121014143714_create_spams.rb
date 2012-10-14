class CreateSpams < ActiveRecord::Migration
  def change
    create_table :spams do |t|
      t.integer :target_id

      t.timestamps
    end
  end
end
