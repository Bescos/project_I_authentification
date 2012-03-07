class AddLastNameFirstName < ActiveRecord::Migration
  def up
    add_column :users, :last_name, :string
    add_column :users, :first_name, :string
  end

  def down
    remove_column :users, :last_name
    remove_column :users, :first_name
  end
end
