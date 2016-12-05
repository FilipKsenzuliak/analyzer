class AddKeyToSynonym < ActiveRecord::Migration
  def change
  	add_column :synonyms, :event_id, :integer
    add_index :synonyms, :event_id
  end
end
