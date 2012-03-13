class AddSecret < ActiveRecord::Migration
  def up
    add_column :applications, :secret, :string
  end

  def down
    remove_column :applications, :secret
  end
end
