class AddNameUrl < ActiveRecord::Migration
  def up
    add_column :applications, :name, :string
    add_column :applications, :url, :string
  end

  def down
    remove_column :applications, :name
    remove_column :applications, :url
  end
end
