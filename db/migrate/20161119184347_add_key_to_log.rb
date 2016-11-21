class AddKeyToLog < ActiveRecord::Migration
  def change
    add_column :logs, :pattern_id, :integer
    add_index :logs, :pattern_id
  end
end
