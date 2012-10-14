class ChangeSpamsTargetIdToString < ActiveRecord::Migration
  def up
    change_column :spams, :target_id, :string
  end

  def down
    change_column :spams, :target_id, :integer
  end
end
