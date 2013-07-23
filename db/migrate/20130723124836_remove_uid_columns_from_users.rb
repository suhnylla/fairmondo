class RemoveUidColumnsFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :uid
    remove_column :users, :uid_confirmed
  end

  def down
    add_column :users, :uid_confirmed, :boolean
    add_column :users, :uid, :string
  end
end
