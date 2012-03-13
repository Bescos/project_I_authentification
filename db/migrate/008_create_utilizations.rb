class CreateUtilizations < ActiveRecord::Migration
  def up
    create_table :utilizations do |t|
    end
  end

  def down
    destroy_table :utilizations
  end
end
