class AddUserid < ActiveRecord::Migration
  def up
    add_column :applications, :user_id, :integer
  end

  def down
    remove_column :applications, :user_id
  end
end
