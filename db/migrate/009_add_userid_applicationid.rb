class AddUseridApplicationid < ActiveRecord::Migration
  def up
    add_column :utilizations, :user_id, :string
    add_column :utilizations, :application_id, :string
  end

  def down
    remove_column :utilizations, :user_id
    remove_column :utilizations, :application_id
  end
end
