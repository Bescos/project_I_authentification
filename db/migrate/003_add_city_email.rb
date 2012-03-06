class AddCityEmail < ActiveRecord::Migration
  def up
    add_column :users, :city, :string
    add_column :users, :email, :string
  end

  def down
    remove_column :users, :city
    remove_column :users, :email
  end
end
